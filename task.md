# Checklist de Implementación: Misión Switch 2

## Fase 1: Modularización y Modelo Multiusuario ✅
- [x] Modelo `Perfil` independiente (Hive `typeId: 1`).
- [x] Adaptadores Hive regenerados.
- [x] `auth_provider.dart` (PIN padre).
- [x] `perfiles_provider.dart` (CRUD perfiles + finanzas).
- [x] `tarea_provider.dart` (filtrado por `perfilId`).

## Fase 2: Arquitectura de UI ✅
- [x] Separación de `main.dart` en múltiples archivos.
- [x] `seleccion_perfil_screen.dart` (tipo Netflix).
- [x] `setup_familia_screen.dart` (wizard de Onboarding).
- [x] `admin_screen.dart` (tabs dinámicas por hijo).
- [x] `home_nino_screen.dart` (dashboard niño).
- [x] `formulario_perfil_screen.dart` (agregar nuevo perfil).
- [x] `formulario_tarea.dart` (BottomSheet avanzado).

## Fase 3: Rediseño Premium y Sincronización ✅
- [x] Estética Premium (gradientes, animaciones, sombras).
- [x] UX mejorada en dashboard niño y panel padres.
- [x] Respaldo GitHub en repositorio privado con PAT.
- [x] Restauración de estructura de ramas (`main` vs `feature`).

## Fase 4: Integración con la Nube (Firebase) 🔜
- [ ] Migración de local (Hive) a la nube (Firestore).
- [ ] Sincronización multi-dispositivo.
- [ ] Notificaciones push.
