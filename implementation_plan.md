# Plan de Implementación: Recordatorios de Misiones en Segundo Plano ⏰

Este plan describe la incorporación de notificaciones locales nativas para recordar al niño sus tareas pendientes cuando la aplicación está minimizada (background) o cerrada.

## User Review Required

> [!IMPORTANT]
> **Compatibilidad de Plataformas e Inicialización:**
> 1. Para iOS y Android se requiere solicitar permisos de notificación explísitos la primera vez que se accede al panel de niños.
> 2. En Android 13+ (API 33+), se activará el diálogo nativo de solicitud de permiso `POST_NOTIFICATIONS`.
> 3. En Android, para asegurar recordatorios exactos (ej. cada X minutos de retraso) usaremos alarmas de sistema, lo cual requiere registrar receptores nativos en el `AndroidManifest.xml`.

## Proposed Changes

### Dependencias y Configuración Base

#### [MODIFY] [pubspec.yaml](file:///c:/Users/angel/josue_tareas/pubspec.yaml)
*   Añadir las dependencias para alertas locales y zonas horarias:
    *   `flutter_local_notifications: ^17.0.0` (o versión compatible determinada por flutter pub)
    *   `timezone: ^0.9.4` (necesaria para la programación de notificaciones basada en horas de calendario)

#### [MODIFY] [AndroidManifest.xml](file:///c:/Users/angel/josue_tareas/android/app/src/main/AndroidManifest.xml)
*   Añadir permisos nativos de vibración, arranque del dispositivo (para reprogramar alertas tras apagar/encender) y notificaciones:
    ```xml
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" android:maxSdkVersion="32" />
    <uses-permission android:name="android.permission.USE_EXACT_ALARM" />
    ```
*   Registrar los `receivers` necesarios para que las alarmas despierten al dispositivo:
    ```xml
    <receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" android:exported="true" />
    <receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver" android:exported="true">
        <intent-filter>
            <action android:name="android.intent.action.BOOT_COMPLETED"/>
            <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
        </intent-filter>
    </receiver>
    ```

---

### Componentes de Notificación

#### [NEW] [notification_service.dart](file:///c:/Users/angel/josue_tareas/lib/services/notification_service.dart)
*   Crear una clase singleton `NotificationService` con las siguientes responsabilidades:
    *   `inicializar()`: Inicializa el plugin, establece la zona horaria local (`tz.initializeDatabase()`) y crea el canal de misiones ("Canal de Recordatorios", ID: `mission_reminders`, importancia alta y vibración).
    *   `solicitarPermisos()`: Pide permisos en iOS (`requestPermissions`) y dispara la petición en Android 13+.
    *   `programarNotificacion(int id, String titulo, String cuerpo, DateTime fecha)`: Programa una alerta nativa para un momento futuro usando `zonedSchedule`.
    *   `cancelarTodas()`: Limpia todas las alertas planificadas en el sistema operativo.

#### [MODIFY] [main.dart](file:///c:/Users/angel/josue_tareas/lib/main.dart)
*   Llamar a `NotificationService.inicializar()` en el método `main()` antes de iniciar la app.

---

### Lógica de Segundo Plano

#### [MODIFY] [reminder_service.dart](file:///c:/Users/angel/josue_tareas/lib/services/reminder_service.dart)
*   Añadir `WidgetsBindingObserver` a la clase `_ReminderServiceState` para reaccionar al ciclo de vida de la aplicación.
*   **En Primer Plano (Foreground):**
    *   El funcionamiento del `Timer.periodic` actual se mantiene intacto (comprobación por minuto, snackbar y reproducción rápida de audio local mediante `SoundService.playReminder()`). Esto ahorra overhead de notificaciones del sistema mientras la app está abierta.
*   **Al pasar a Segundo Plano / Minimizar (`AppLifecycleState.paused`):**
    *   Verificar si el perfil seleccionado tiene misiones pendientes para la jornada actual o atrasadas.
    *   Si existen misiones pendientes, calcular el intervalo `frecuenciaRecordatorio` del niño (ej. 10 minutos).
    *   Planificar **5 notificaciones consecutivas** a futuro (ej. en `T+10min`, `T+20min`, `T+30min`, `T+40min`, `T+50min`).
    *   El contenido recordará al niño: *"¡Hola [Nombre]! Aún tienes [N] misiones esperando por ti. ¡Vamos a completarlas! 🚀"*
*   **Al regresar a Primer Plano (`AppLifecycleState.resumed`):**
    *   Ejecutar `NotificationService.cancelarTodas()`. Esto remueve inmediatamente las notificaciones planificadas, evitando que suonen alertas obsoletas mientras la app está activa.
*   **En la aprobación o cambio de estado de tareas:**
    *   Si el niño completa las misiones y la lista de tareas activas queda vacía, se limpia cualquier alerta programada.

---

## Plan de Verificación

### Pruebas Manuales
1.  **Validación de Permisos:** Al ingresar a la pantalla de un niño, verificar que aparezca la solicitud de permisos de notificación.
2.  **Alerta en Foreground:** Con la app abierta, comprobar que a los 10 minutos (o el intervalo configurado) se reproduzca el sonido y aparezca el snackbar tradicional.
3.  **Alerta en Background:** Con tareas pendientes, minimizar la app (o bloquear la pantalla) y comprobar que a los X minutos se reciba una notificación nativa del sistema en la barra de tareas.
4.  **Cancelación Automática:** Abrir la app tras recibir una notificación nativa, verificar que no suenen las notificaciones posteriores planificadas (cancelación exitosa al resume).
