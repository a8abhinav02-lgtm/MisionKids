# Checklist de Mejoras DOFA: Mission Kids 🏁

Este listado agrupa las oportunidades de mejora identificadas en el diagnóstico de producción del proyecto, organizadas por prioridad de ejecución.

## Prioridad Alta: Estabilización y Onboarding ✅
- [x] **Desbloqueo de registro familiar**
  - [x] Crear rama de trabajo `feature/desbloqueo-registro`.
  - [x] Cambiar estado predeterminado de `aprobado` a `true` al registrarse en `auth_provider.dart`.
  - [x] Corregir advertencias de compilación en `perfiles_provider.dart`, `tarea_provider.dart` y `home_nino_screen.dart`.
  - [x] Verificar que el análisis de Flutter pase sin errores ni warnings.
- [x] **Empaquetado de recursos de sonido local**
  - [x] Crear carpeta de assets y descargar sonido de alerta `beep_short.ogg`.
  - [x] Registrar el archivo en el bloque `assets:` de `pubspec.yaml`.
  - [x] Actualizar `SoundService` para utilizar `AssetSource` en lugar de `UrlSource`.
  - [x] Confirmar funcionamiento offline del audio.
- [x] **Cuentas Compartidas (Co-parenting) / Multi-administrador**
  - [x] Crear rama de trabajo `feature/cuentas-compartidas`.
  - [x] Rediseñar base de datos en Firestore (Esquema `/usuarios` y `/familias/{familiaId}`).
  - [x] Crear mapeo de familias y código legible de familia (`MK-XXXXXX`) en `auth_provider.dart`.
  - [x] Implementar migración silenciosa para cuentas de familias clásicas `/familias/{uid}` a `/familias/FAM_{uid}`.
  - [x] Renombrar llamadas y enlazar `PerfilesProvider` y `TareaProvider` a `familiaId` en lugar de `uid`.
  - [x] Modificar `setup_familia_screen.dart` para agregar la opción "Unirse a Familia Existente" con registro y validación de código.
  - [x] Actualizar `admin_screen.dart` para mostrar el código de familia compartida en la Zona de Padres con opción de copiar.
  - [x] Validar y compilar sin advertencias.

## Prioridad Media: Experiencia y Seguridad 🛠️
- [x] **Recordatorios de misiones en segundo plano (App Cerrada)**
  - [x] Agregar dependencias `flutter_local_notifications` y `timezone` en `pubspec.yaml`.
  - [x] Configurar permisos nativos en `AndroidManifest.xml` (Android) y `Info.plist` (iOS).
  - [x] Implementar un servicio de notificaciones locales (`NotificationService`).
  - [x] Integrar `WidgetsBindingObserver` en `ReminderService` para programar notificaciones locales en intervalos cuando la app pasa al segundo plano (background) si hay tareas pendientes.
  - [x] Cancelar todas las notificaciones programadas al regresar al primer plano (foreground) o cuando se completen las tareas.
  - [x] Validar el correcto funcionamiento de las alertas nativas.
- [ ] **Encriptación de credenciales locales (PIN de Padres)**
  - [ ] Agregar dependencias `flutter_secure_storage` y configurar caja encriptada de Hive.
  - [ ] Migrar el PIN del padre existente a almacenamiento seguro.
  - [ ] Asegurar lectura y escritura encriptada en el flujo de verificación.

## Prioridad Baja: Escalabilidad y Analíticas 📈
- [ ] **Gráficos de hábitos para padres**
  - [ ] Agregar dependencia `fl_chart`.
  - [ ] Crear vista de analíticas en la Zona de Padres con resúmenes semanales de cumplimiento.
- [ ] **Notificaciones Push cruzadas (Firebase Cloud Messaging)**
  - [ ] Configurar Firebase Cloud Messaging en la consola de Firebase.
  - [ ] Integrar permisos y token de notificaciones FCM.
  - [ ] Implementar envío de alertas cruzadas (Aprobaciones/Nuevos retos).
