# Checklist de Implementación: Misión Switch 2

## Fase 1: Modularización y Modelo Multiusuario
- [x] Crear modelo `perfil_model.dart` (id, nombre, tematica, color, saldo, meta)
- [x] Modificar `tarea_model.dart` — campo `perfilId`
- [x] Generar adaptadores de Hive (`build_runner`)
- [x] Crear `auth_provider.dart` (PIN padre)
- [x] Crear `perfiles_provider.dart` (CRUD perfiles + finanzas por hijo)
- [x] Refactorizar `tarea_provider.dart` (filtrado por `perfilId`, sin finanzas)

## Fase 2: Modularización UI
- [x] `main.dart` simplificado (~40 líneas)
- [x] `seleccion_perfil_screen.dart` (pantalla tipo Netflix)
- [x] `setup_familia_screen.dart` (wizard PIN + primer hijo)
- [x] `admin_screen.dart` (panel padres con tabs por hijo)
- [x] `home_nino_screen.dart` (dashboard adaptativo por tema)
- [x] `historial_screen.dart` (trofeos y logros del día)
- [x] `formulario_perfil_screen.dart` (agregar nuevos hijos)
- [x] `formulario_tarea.dart` (widget reutilizable con plantillas rápidas)
- [x] `app_theme.dart` (colores, avatares, gradientes, ThemeData)

## Fase 3: Rediseño UX/UI Premium
- [x] Selección de Perfil — fondo oscuro, avatares animados con glow
- [x] Setup Familia — wizard 2 pasos, selectores con etiquetas y glow
- [x] Panel de Padres — header oscuro, botón "Agregar Hijo" prominente, tabs con avatar + indicador dorado
- [x] Dashboard Niño — gradiente, saludo dinámico, tarjeta glassmorphic, tareas tapeables
- [x] Formulario Tareas — plantillas rápidas, switch obligatoria, frecuencia, jornada, íconos

## Fase 4: Integración con la Nube (Firebase) — PENDIENTE
- [ ] Migrar Hive → Firebase Firestore
- [ ] Sincronización en tiempo real entre dispositivos
- [ ] Firebase Auth (reemplazar PIN local)
- [ ] Notificaciones push
