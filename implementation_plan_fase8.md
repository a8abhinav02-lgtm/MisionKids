# Plan de Implementación: Fase 8 - Organización, Estética y Recordatorios 🚀

Este plan busca elevar la calidad operativa de **Mission Kids** mejorando la visualización del administrador y añadiendo una capa de alertas auditivas para asegurar el cumplimiento de las tareas.

## User Review Required

> [!IMPORTANT]
> **Sobre los Recordatorios Sonoros**: 
> Para que el sonido funcione en el dispositivo del padre cuando el niño tiene tareas pendientes, la App debe estar abierta (en primer plano) o debemos implementar **Notificaciones Push (FCM)**. 
> *   **Propuesta inicial**: Implementaremos una alerta sonora que se dispara si la App está abierta y detecta tareas obligatorias pendientes cerca del fin de su bloque horario.
>
> **Categorías de Tareas**: 
> Como el modelo actual no tiene categorías, añadiré un campo de `categoria` (Higiene, Hogar, Estudio, Otros). ¿Estás de acuerdo con estas categorías iniciales?

## Proposed Changes

### 1. Modelo de Datos (`tarea_model.dart`)
#### [MODIFY] [tarea_model.dart](file:///c:/Users/angel/josue_tareas/lib/models/tarea_model.dart)
- Añadir campo `String categoria`.
- Actualizar `toMap` y `fromMap` para persistencia en Firestore.
- *Nota: Será necesario regenerar el adaptador de Hive.*

### 2. Interfaz de Administrador (`admin_screen.dart`)
#### [MODIFY] [admin_screen.dart](file:///c:/Users/angel/josue_tareas/lib/ui/screens/admin_screen.dart)
- **Agrupamiento**: Organizar la lista de misiones mediante un `ExpansionTile` o encabezados por **Categoría**.
- **Orden Cronológico**: Dentro de cada categoría, ordenar las tareas por bloque: Mañana > Tarde > Noche.
- **Efecto de Atenuación**: Si a una tarea `estaAprobada`, se le aplicará:
    - `Opacity(0.5)`
    - Grayscale (Escala de grises) en el icono.
    - Desactivación de botones de aprobación para evitar duplicidad.

### 3. Sistema de Recordatorios Sonoros
#### [NEW] `lib/services/notification_service.dart` (o similar)
- Lógica para reproducir un sonido breve (ej: un "Ding" o campana).
- **Sincronización**: Un listener en el `TareaProvider` que verifique si hay tareas pendientes al entrar en los últimos 30 minutos de un bloque horario.

## Open Questions

- **¿Qué sonidos prefieres?** ¿Uno suave tipo notificación o algo más persistente?
- **¿Deseas que las categorías sean fijas (dropdown) o que el padre pueda escribir la que quiera?** Recomiendo una lista fija para mantener el orden.

## Verification Plan

### Manual Verification
1.  Crear misiones con diferentes categorías y bloques.
2.  Verificar que en el panel Admin aparezcan agrupadas y en orden (Mañana -> Noche).
3.  Aprobar una tarea y confirmar que se vuelve "borrosa/atenuada".
4.  Simular (adelantando el reloj o esperando) que una tarea obligatoria está por vencer y verificar si suena la alerta tanto en el perfil del niño como en el del padre.
