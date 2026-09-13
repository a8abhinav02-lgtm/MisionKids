import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> inicializar() async {
    if (kIsWeb) return;
    // 1. Inicializar base de datos de zonas horarias
    tz.initializeTimeZones();

    // 2. Configuración para Android utilizando el icono de la app
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. Configuración para iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // 4. Configuración combinada
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // 5. Inicializar el plugin
    await _notificationsPlugin.initialize(initializationSettings);

    // 6. Crear canales de notificaciones en Android
    if (Platform.isAndroid) {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      const AndroidNotificationChannel channelReminders = AndroidNotificationChannel(
        'mission_reminders',
        'Recordatorios de Misiones',
        description: 'Canal para alertas de misiones pendientes',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      const AndroidNotificationChannel channelFamilyAlerts = AndroidNotificationChannel(
        'family_alerts',
        'Conexión Familiar Misión Kids',
        description: 'Alertas inmediatas de tareas completadas y aprobadas entre padres e hijos',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      await androidPlugin?.createNotificationChannel(channelReminders);
      await androidPlugin?.createNotificationChannel(channelFamilyAlerts);
    }
  }

  static Future<void> solicitarPermisos() async {
    if (kIsWeb) return;
    if (Platform.isAndroid) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  static Future<void> programarNotificacion({
    required int id,
    required String titulo,
    required String cuerpo,
    required DateTime programacion,
  }) async {
    if (kIsWeb) return;
    final tzDateTime = tz.TZDateTime.from(programacion, tz.local);

    // Evitar programar en el pasado
    if (tzDateTime.isBefore(DateTime.now())) return;

    await _notificationsPlugin.zonedSchedule(
      id,
      titulo,
      cuerpo,
      tzDateTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'mission_reminders',
          'Recordatorios de Misiones',
          channelDescription: 'Canal para alertas de misiones pendientes',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> mostrarNotificacionInmediata({
    required int id,
    required String titulo,
    required String cuerpo,
    String? payload,
  }) async {
    if (kIsWeb) return;
    try {
      await _notificationsPlugin.show(
        id,
        titulo,
        cuerpo,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'family_alerts',
            'Conexión Familiar Misión Kids',
            channelDescription: 'Alertas inmediatas de tareas completadas y aprobadas entre padres e hijos',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payload,
      );
    } catch (_) {
      // Degrada silenciosamente en caso de falta de soporte nativo en el entorno
    }
  }

  static Future<void> cancelarTodas() async {
    if (kIsWeb) return;
    await _notificationsPlugin.cancelAll();
  }
}
