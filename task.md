# Checklist de Implementación: Refactor Multiusuario

- [x] Configurar la estructura de directorios y modelos de datos
  - [x] Crear modelo `perfil_model.dart`
  - [x] Modificar `tarea_model.dart` para soportar perfiles (`perfilId`)
  - [x] Generar adaptadores de Hive (`build_runner`)
- [x] Separar la lógica en Providers
  - [x] Crear `auth_provider.dart` o integrar lógica Admin.
  - [x] Crear `perfil_provider.dart` (Gestión de perfiles, saldos, meta y temas)
  - [x] Refactorizar `tarea_provider.dart` (Filtrado por `perfilId`, limpieza)
- [x] Implementar el motor de Temas y Avatares
  - [x] Crear `app_theme.dart` (Temáticas como Astronauta, Ninja, Princesa)
- [x] Modularizar la Interfaz Gráfica (`main.dart` -> `screens/` & `widgets/`)
  - [x] `main.dart` simplificado
  - [x] `seleccion_perfil_screen.dart` (Pantalla tipo Netflix)
  - [x] `setup_perfil_screen.dart` (Configurar nuevo perfil y admin)
  - [x] `admin_screen.dart` (Zona de Padres multihijo)
  - [x] `home_nino_screen.dart` (Dashboard adaptativo por tema)
  - [x] `historial_nino_screen.dart`
- [x] Verificación Final y Pruebas Locales
