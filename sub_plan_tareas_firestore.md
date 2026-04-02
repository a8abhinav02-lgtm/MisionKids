# Detalle Técnico: Migración de TareaProvider a Firestore

Este sub-plan detalla cómo convertiremos el gestor de tareas local (Hive) en uno basado en la nube (Firestore) para cumplir con la Fase 4.3.

## Estructura de Datos en Firestore

Las tareas se almacenarán en una sub-colección por familia para garantizar la privacidad:
`familias/{uid}/tareas/{tareaId}`

Cada documento contendrá el esquema completo definido en `Tarea.toMap()`, incluyendo el `perfilId` para filtrar por niño.

## User Review Required

> [!IMPORTANT]
> **Migración Automática**: Al iniciar la App por primera vez con la nueva versión, detectaremos si tienes tareas guardadas solo en tu teléfono (Hive). Si es así, las subiremos automáticamente a tu nueva cuenta de Firebase para que no pierdas nada.

---

## Proposed Changes

### [MODIFY] [tarea_provider.dart](file:///c:/Users/angel/josue_tareas/lib/providers/tarea_provider.dart)

#### 1. Gestión de Identidad
Añadiremos `_uid` y el método `updateUid(String uid)` para que el provider sepa qué base de datos de familia debe escuchar.

#### 2. Escucha en Tiempo Real
Sustituiremos la lista estática por un `Stream` de Firestore:
```dart
_db.collection('familias').doc(_uid).collection('tareas')
   .snapshots().listen((snapshot) { ... });
```

#### 3. Refactorización de CRUD (Misiones)
Actualizaremos los métodos clave:
- `agregarTarea`: Ahora usará `_db.collection(...).add(...)`.
- `aprobarTarea` / `rechazarTarea`: Actualizarán el estado directamente en el documento de Firestore.
- `aplicarSancion`: Creará un documento de tipo sanción en la nube.

#### 4. Lógica de "Limpieza de Día"
La lógica que reinicia las tareas diarias a "pendiente" se ejecutará comparando la fecha del servidor o la fecha local con el campo `ultimoDiaCompletado` almacenado en Firestore.

---

## Verification Plan

### Automated Verification
- Se verificará que al agregar una tarea en un dispositivo, aparezca en la consola de Firebase con el `perfilId` correcto.

### Manual Verification
1. Abrir la App en un dispositivo.
2. Crear una tarea.
3. Verificar que la tarea aparezca en un segundo dispositivo logueado con la misma cuenta.
