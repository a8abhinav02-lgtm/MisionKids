# Plan de Implementación: Condicionar Puntos a Tareas Obligatorias

Actualmente, las tareas opcionales (que otorgan saldo) pueden ser aprobadas y sumar puntos en la cartera del niño sin importar si ha completado sus responsabilidades obligatorias diarias ("Llaves 🔑"). 

Este plan modificará la lógica para que las responsabilidades básicas se cumplan primero.

## User Review Required

> [!IMPORTANT]
> **Decisión de Diseño**: Selecciona una de las siguientes opciones para implementar la restricción.
> 
> **Opción A (Recomendada - Validar al Aprobar):** 
> Cuando el padre intente **aprobar** una tarea opcional que otorga puntos, la aplicación validará si el niño tiene tareas obligatorias ("Llaves") pendientes para *hoy*. Si hay pendientes, no dejará aprobar la opcional ni sumar puntos y mostrará un mensaje: "⚠️ El niño debe completar todas sus responsabilidades obligatorias de hoy primero".
> 
> **Opción B (Validar desde el lado del Niño):** 
> El niño no podrá siquiera seleccionar (enviar a revisión) tareas opcionales desde su panel de inicio hasta que haya enviado a revisión todas sus tareas obligatorias ("Llaves") de ese día.
> 
> *¿Qué opción prefieres que ejecute? Personalmente, recomiendo la **Opción A**, porque mantiene al Padre con el control absoluto en el panel de administrador.*

## Proposed Changes

### 1. Proveedor de Tareas (`tarea_provider.dart`)
#### [MODIFY] `lib/providers/tarea_provider.dart`
- Agregar la función `bool tieneObligatoriasPendientes(String perfilId)`:
  - Filtrará todas las tareas programadas para el día de hoy.
  - Devolverá `true` si al menos una de ellas tiene `esObligatoria == true` y no está aprobada hoy.

### 2. Panel de Aprobación de Padres (`admin_screen.dart`)
#### [MODIFY] `lib/ui/screens/admin_screen.dart`
- En la acción de "Aprobar Tarea":
  - Si la tarea a aprobar otorga puntos y `tieneObligatoriasPendientes` es `true`, lanzar un indicador SnackBar con color rojo alertando de que las tareas obligatorias deben gestionarse primero.
  - Bloquear el proceso (no sumar el saldo ni marcar la opcional como aprobada).

## Verification Plan

### Manual Verification
1. Ingresar como administrador.
2. Comprobar que en un perfil con tareas obligatorias inactivas/pendientes no se puedan aprobar tareas de puntos usando los botones de "Esperando Aprobación".
3. Completar (Aprobar) todas las obligatorias.
4. Intentar de nuevo verificar la tarea de puntos y asegurar que el saldo suba de manera exitosa.
