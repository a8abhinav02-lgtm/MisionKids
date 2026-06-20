# Plan de Implementación: Optimización de Alarma y Sonidos de Notificación

Este plan analiza y propone soluciones para la observación sobre el sonido de alerta corto (~1s), garantizando una experiencia audible en la aplicación nativa mientras se respetan las limitaciones técnicas de la versión web.

## Análisis del Problema

1. **En Primer Plano (Foreground - App Abierta):**
   - Actualmente, `SoundService.playReminder()` reproduce el archivo `assets/sounds/beep_short.ogg`.
   - **Causa del sonido corto:** Este archivo de audio es inherentemente corto (menos de 1 segundo) y se reproduce una única vez.
   - **En la Web:** Los navegadores web bloquean el "autoplay" de audio si el usuario no ha interactuado primero con la pestaña (políticas de seguridad de gestos). Por lo tanto, el sonido en primer plano solo suena en la web si el usuario ya ha hecho clic en algún lugar de la pantalla.

2. **En Segundo Plano (Background - App Cerrada/Minimizada):**
   - El servicio `ReminderService` programa notificaciones nativas a través del plugin `flutter_local_notifications`.
   - **Causa del sonido corto:** El canal de Android `mission_reminders` utiliza el sonido por defecto del sistema (un "chime" corto de notificación determinado por la configuración del teléfono del usuario).
   - **En la Web:** No es posible reproducir audios locales personalizados en segundo plano de manera persistente como en un sistema operativo móvil nativo (se requerirían Service Workers complejos con Push API y, aún así, el control del sonido está sumamente restringido por el navegador/OS). Por ende, esta mejora es exclusiva para la versión instalada (móvil).

---

## Propuesta de Solución

Proponemos abordar esto en dos áreas: primer plano (dentro de la app activa) y segundo plano (notificación nativa del sistema).

### Área A: Bucle o Sonido Prolongado en Primer Plano

Para evitar que el sonido de alerta pase desapercibido dentro de la app:
- **Opción A.1: Reproducción en bucle temporal.** Configurar `AudioPlayer` en modo bucle (`ReleaseMode.loop`) para reproducir el pitido continuamente durante un tiempo controlado (por ejemplo, 6 a 8 segundos o hasta que el usuario cierre el banner/SnackBar de notificación), y luego detenerlo automáticamente.
- **Opción A.2: Cambiar a un archivo de audio más largo.** Reemplazar `beep_short.ogg` por un archivo de audio con un patrón de alarma de 5 a 10 segundos de duración.

---

### Área B: Personalización del Sonido de Notificación en Segundo Plano (Móvil)

Para que las notificaciones del sistema móvil suenen más fuerte o durante más tiempo como una alarma real:

#### En Android:
1. **Recurso de Sonido Nativo:** Crear el directorio de recursos nativos `android/app/src/main/res/raw/` y colocar un sonido de alarma más perceptible (por ejemplo, `alarm_sound.mp3`).
2. **Actualización de Canal de Notificaciones:** En `NotificationService.inicializar()`, crear un nuevo canal de notificaciones (por ejemplo, ID: `mission_alerts_channel`) configurado para utilizar este sonido nativo personalizado:
   ```dart
   const AndroidNotificationDetails(
     'mission_alerts_channel',
     'Alertas de Misiones',
     sound: RawResourceAndroidNotificationSound('alarm_sound'),
     playSound: true,
     importance: Importance.max,
     priority: Priority.high,
   )
   ```
   *Nota: Se debe usar un ID de canal nuevo porque Android no permite modificar las propiedades de sonido de canales ya registrados en el dispositivo.*

#### En iOS:
1. Colocar el sonido en formato compatible (ej. `.caf` o `.wav`) dentro del bundle de la app.
2. Configurar `DarwinNotificationDetails(sound: 'alarm_sound.wav')`.

---

## Plan de Verificación

### Pruebas Manuales
- **Prueba en Primer Plano:** Iniciar la app, esperar el recordatorio periódico, verificar que el sonido se escuche en bucle/prolongado y se detenga adecuadamente.
- **Prueba en Segundo Plano:** Minimizar la app, esperar a que se cumpla el tiempo del recordatorio, y verificar que el dispositivo móvil emita la alerta con el sonido de alarma personalizado y no el tono corto genérico del sistema.

---

> [!IMPORTANT]
> **User Review Required**
> Por favor, revisa estas opciones y confírmanos:
> 1. ¿Deseas aplicar el bucle/prolongación en primer plano (Área A)? ¿Qué duración sugerida prefieres (ej. 5 segundos)?
> 2. ¿Deseas implementar el sonido personalizado nativo para el segundo plano (Área B)? En caso afirmativo, ¿tienes algún sonido específico o podemos proveer un tono de alarma estándar?
