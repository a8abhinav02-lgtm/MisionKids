# Refactorización Multiusuario + UX Premium

## Resumen del Objetivo

Reestructurar la aplicación **Misión Switch 2** para soportar múltiples perfiles de niños con temas personalizados, modularizar el código monolítico, y elevar la experiencia visual a un nivel premium. La integración con Firebase queda aplazada hasta validar todo en local.

---

## Fase 1: Modularización y Modelo Multiusuario ✅ COMPLETADA

### Modelos de Datos (Hive)

#### [NEW] [perfil_model.dart](file:///c:/Users/angel/josue_tareas/lib/models/perfil_model.dart)
Modelo `Perfil` con campos: `id`, `nombre`, `tematica`, `colorPrimario`, `saldo`, `metaAhorro`, `nombreMeta`, `historialVictorias`. Cada hijo tiene su propio perfil con saldo y metas independientes.

#### [MODIFY] [tarea_model.dart](file:///c:/Users/angel/josue_tareas/lib/models/tarea_model.dart)
Se añadió el campo `perfilId` (HiveField 10) para vincular cada tarea a un niño específico. Adaptadores regenerados con `build_runner`.

---

### Providers (Lógica separada por responsabilidad)

#### [NEW] [auth_provider.dart](file:///c:/Users/angel/josue_tareas/lib/providers/auth_provider.dart)
Maneja exclusivamente la autenticación del padre (PIN). Caja Hive independiente: `caja_auth_v2`.

#### [NEW] [perfiles_provider.dart](file:///c:/Users/angel/josue_tareas/lib/providers/perfiles_provider.dart)
CRUD de perfiles de niños + gestión financiera por perfil (saldo, metas, historial de victorias, reclamar premios). Caja Hive: `caja_perfiles_v2`.

#### [MODIFY] [tarea_provider.dart](file:///c:/Users/angel/josue_tareas/lib/providers/tarea_provider.dart)
Depurado: ya no maneja finanzas ni autenticación. Todos los métodos filtran por `perfilId`. Caja Hive: `caja_tareas_v6`.

---

### Temas y Personalización

#### [NEW] [app_theme.dart](file:///c:/Users/angel/josue_tareas/lib/ui/themes/app_theme.dart)
Motor de temas con:
- **8 paletas de color** (azul, rojo, verde, morado, naranja, rosa, dorado, índigo)
- **7 avatares temáticos** (Ninja, Astronauta, Princesa, Deportes, Estudiante, Héroe, Robot)
- Métodos para gradientes (`getGradient`, `getDarkGradient`), ThemeData dinámico, y etiquetas legibles

---

## Fase 2: Modularización UI ✅ COMPLETADA

El archivo `main.dart` original (760 líneas) fue eliminado y reemplazado por:

#### [MODIFY] [main.dart](file:///c:/Users/angel/josue_tareas/lib/main.dart)
Punto de entrada simplificado (~40 líneas). Solo inicializa Hive, registra adaptadores y configura `MultiProvider` con los 3 providers.

#### [NEW] [seleccion_perfil_screen.dart](file:///c:/Users/angel/josue_tareas/lib/ui/screens/seleccion_perfil_screen.dart)
Pantalla inicial tipo "Netflix" para elegir quién usa la app. Muestra avatares de los hijos y un botón para padres.

#### [NEW] [setup_familia_screen.dart](file:///c:/Users/angel/josue_tareas/lib/ui/screens/setup_familia_screen.dart)
Wizard de 2 pasos para la configuración inicial: (1) PIN del padre, (2) Perfil del primer hijo con avatar y color.

#### [NEW] [home_nino_screen.dart](file:///c:/Users/angel/josue_tareas/lib/ui/screens/home_nino_screen.dart)
Dashboard del niño con header adaptativo al color de su perfil, saldo, progreso de meta y lista de misiones por bloque horario.

#### [NEW] [admin_screen.dart](file:///c:/Users/angel/josue_tareas/lib/ui/screens/admin_screen.dart)
Panel de padres con tabs por cada hijo. Incluye resumen del perfil, aprobación de misiones, gestión de retos y sanciones.

#### [NEW] [historial_screen.dart](file:///c:/Users/angel/josue_tareas/lib/ui/screens/historial_screen.dart)
Tabs con logros del día y trofeos históricos, tematizado por el color del niño activo.

#### [NEW] [formulario_perfil_screen.dart](file:///c:/Users/angel/josue_tareas/lib/ui/screens/formulario_perfil_screen.dart)
Pantalla para agregar nuevos hijos desde el panel de padres (seleccionando nombre, avatar y color).

#### [NEW] [formulario_tarea.dart](file:///c:/Users/angel/josue_tareas/lib/ui/widgets/formulario_tarea.dart)
Widget reutilizable (BottomSheet) para crear/editar misiones con: plantillas rápidas, switch obligatoria, frecuencia (diaria/semanal/fecha fija), jornada, y selector de ícono.

---

## Fase 3: Rediseño UX/UI Premium ✅ COMPLETADA

### Cambios aplicados:

| Pantalla | Mejora |
|---|---|
| **Selección de Perfil** | Fondo degradado oscuro premium. Avatares con animación de pulso y sombra glow del color del niño. |
| **Setup Familia** | Wizard con indicador de pasos visual. Selectores de avatar con etiquetas. Colores con check y glow animado. |
| **Panel de Padres** | Header oscuro con gradientes. Botón "Agregar Hijo" prominente con gradiente azul brillante. Tabs con ícono del avatar + indicador de selección dorado con glow. Tarjeta resumen con gradiente del color del niño (saldo y meta integrados). Botones de acción rápida (Editar Reto / Multa). |
| **Dashboard del Niño** | Header con gradiente del color del perfil. Saludo dinámico contextual ("Buenos días ☀️"). Tarjeta glassmorphic de saldo. Zona de misiones con fondo redondeado. Tarjetas de misión tapeables con InkWell y ícono `touch_app`. |
| **Formulario de Tareas** | Recuperado con plantillas rápidas, switch obligatoria funcional, frecuencia, jornada y selector de íconos. |

---

## Fase 4: Integración con la Nube 🔜 PENDIENTE

> [!IMPORTANT]
> Esta fase se implementará **solo cuando todo lo anterior sea funcional y validado en local**, según lo acordado.

### Cambios planificados:
- Migrar almacenamiento de Hive (local) a **Firebase Firestore** (nube)
- Sincronización en tiempo real entre dispositivos de la familia
- Autenticación con Firebase Auth (reemplazar PIN local)
- Notificaciones push para padre e hijos

---

## Estructura Actual del Proyecto

```
lib/
├── main.dart                          # Entry point (~40 líneas)
├── models/
│   ├── perfil_model.dart              # Modelo Perfil (Hive typeId: 1)
│   ├── perfil_model.g.dart            # Generado
│   ├── tarea_model.dart               # Modelo Tarea (Hive typeId: 0)
│   └── tarea_model.g.dart             # Generado
├── providers/
│   ├── auth_provider.dart             # Autenticación padre
│   ├── perfiles_provider.dart         # CRUD perfiles + finanzas
│   └── tarea_provider.dart            # CRUD tareas + flujo operativo
└── ui/
    ├── screens/
    │   ├── admin_screen.dart          # Panel de padres (tabs por hijo)
    │   ├── formulario_perfil_screen.dart  # Agregar nuevo hijo
    │   ├── historial_screen.dart      # Trofeos y logros del día
    │   ├── home_nino_screen.dart      # Dashboard del niño
    │   ├── seleccion_perfil_screen.dart   # "¿Quién eres?"
    │   └── setup_familia_screen.dart  # Wizard inicial (PIN + primer hijo)
    ├── themes/
    │   └── app_theme.dart             # Colores, avatares, gradientes, ThemeData
    └── widgets/
        └── formulario_tarea.dart      # BottomSheet crear/editar misión
```

## Rama Git

Todos los cambios están en la rama `feature/refactor-multiusuario`, sin afectar `main`.
