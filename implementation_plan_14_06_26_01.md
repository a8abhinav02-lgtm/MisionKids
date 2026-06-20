# Plan de Implementación: Nuevo Flujo de Ingreso y Sistema de Aprobación 🛡️

Este plan detalla los pasos para reestructurar el flujo de registro de nuevos copadres y establecer un sistema de autorización por parte del administrador principal, tal como propusiste.

## Solución Propuesta y Secuencia Lógica

### 1. Inversión del Flujo de Registro
Para evitar que el usuario se pierda o borre el código familiar entre pantallas, cambiaremos el orden de los pasos al usar la opción "Unirse a Familia Existente":
1. **Paso Inicial (Código):** La aplicación mostrará primero la pantalla del "Código de Familia". Si el usuario ingresó mediante un enlace web con el parámetro `?code=FAM_123`, este campo ya aparecerá completamente rellenado.
2. **Segundo Paso (Credenciales):** Al darle "Siguiente" o "Validar", la aplicación pasará a solicitar el "Correo Electrónico" y la "Contraseña" para crear su cuenta.

### 2. Estado "Pendiente de Aprobación"
Actualmente, cualquier persona que tenga el código familiar ingresa automáticamente. Ahora implementaremos un **Sistema de Solicitudes**:
- Cuando el nuevo usuario se registra y envía el código, su identificador y correo no se añaden a la familia activa inmediatamente. En su lugar, se agregan a una nueva lista en la base de datos llamada `padres_pendientes`.
- En el dispositivo del nuevo usuario, la aplicación lo redirigirá a la pantalla `EsperandoAprobacionScreen` (la pantalla con el ícono de reloj de arena). Quedará bloqueado allí hasta que el creador de la familia lo apruebe.

### 3. Zona de Validación para el Administrador (Padre)
- En el Panel de Administración (Zona de Padres) de la cuenta propietaria, agregaremos una nueva sección llamada **"Solicitudes de Ingreso"**.
- El administrador verá una lista con los correos electrónicos de las personas que intentan unirse a su familia con el código.
- Al presionar **"Aprobar"**, el sistema moverá a ese usuario de la lista de `padres_pendientes` a la de `padres` autorizados.
- Cuando el nuevo usuario presione "Recomprobar" en su pantalla de espera (o reinicie la app), el sistema detectará la aprobación y le dará acceso total a la familia.

---

> [!IMPORTANT]
> **User Review Required**
> Este cambio impactará la base de datos en Firebase (Firestore). Necesitaremos modificar la estructura de los documentos de `familias` para soportar la lista de pendientes y actualizar `admin_screen.dart` para mostrar la interfaz de aprobaciones. ¿Estás de acuerdo con este enfoque y la estructura de seguridad planteada?

## Proposed Changes

### [MODIFY] [setup_familia_screen.dart](file:///c:/Users/angel/josue_tareas/lib/ui/screens/setup_familia_screen.dart)
- Modificar la variable de estado `_step` para el flujo de unirse (`_isJoinFlow`).
- Al seleccionar "Unirse", enviar al usuario directamente al paso del Código Familiar.
- Al validar el código, mover al paso de Correo/Contraseña.
- Al finalizar el registro, ejecutar la lógica de `unirseAFamilia()`.

### [MODIFY] [auth_provider.dart](file:///c:/Users/angel/josue_tareas/lib/providers/auth_provider.dart)
- Cambiar la lógica de `unirseAFamilia()` para que añada al usuario a un array `padres_pendientes` (en lugar de `padres`) y guarde su estado local como `aprobado: false`.
- Actualizar `_sincronizarPinDesdeNube()` para verificar si el usuario está en el array `padres_pendientes` o en `padres` para determinar su acceso en tiempo real.
- Crear funciones para el Administrador: `obtenerSolicitudesPendientes()`, `aprobarUsuario()` y `rechazarUsuario()`.

### [MODIFY] [admin_screen.dart](file:///c:/Users/angel/josue_tareas/lib/ui/screens/admin_screen.dart)
- Agregar una interfaz visual en la parte superior (o como una pestaña nueva) que muestre un listado de solicitudes si existen correos pendientes de autorización.
- Incluir botones para "Aprobar" y "Rechazar".

## Verification Plan

### Manual Verification
1. **Flujo de Usuario Nuevo:** Compartir el enlace web. Entrar con un correo nuevo. Verificar que pide primero el código (ya relleno) y luego las credenciales. Al finalizar, confirmar que se muestra la pantalla "Esperando Aprobación".
2. **Flujo del Administrador:** Entrar a la cuenta original del padre. Ir a la Zona de Padres. Confirmar que aparece la solicitud del nuevo usuario. Presionar "Aprobar".
3. **Comprobación Final:** Volver a la pantalla del nuevo usuario, presionar "Recomprobar" y verificar que el sistema le otorga acceso a la pantalla de selección de perfiles de los niños.
