import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/perfiles_provider.dart';
import '../providers/tarea_provider.dart';
import 'sound_service.dart';
import 'notification_service.dart';

class ReminderService extends StatefulWidget {
  final Widget child;
  const ReminderService({super.key, required this.child});

  @override
  State<ReminderService> createState() => _ReminderServiceState();
}

class _ReminderServiceState extends State<ReminderService> with WidgetsBindingObserver {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _scheduleBackgroundReminders();
    } else if (state == AppLifecycleState.resumed) {
      NotificationService.cancelarTodas();
    }
  }

  void _startTimer() {
    // Revisar cada minuto para encajar con el modulo (ej. minute % 10 == 0)
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkReminders();
    });
  }

  void _scheduleBackgroundReminders() {
    final perfilesProv = Provider.of<PerfilesProvider>(context, listen: false);
    final tareaProv = Provider.of<TareaProvider>(context, listen: false);

    if (perfilesProv.isLoading || tareaProv.isLoading) return;

    final perfilActivo = perfilesProv.perfilActivo;
    if (perfilActivo == null) return;

    // Buscar todas las tareas pendientes del bloque actual o anteriores
    final pendientes = tareaProv.listaTareasActivas(perfilActivo.id).where((t) {
      if (t.estado != 'pendiente') return false;
      
      final bloques = ['manana', 'tarde', 'noche'];
      final indiceTarea = bloques.indexOf(t.bloque);
      final indiceActual = bloques.indexOf(tareaProv.bloqueActual);
      
      return indiceTarea <= indiceActual;
    }).toList();

    if (pendientes.isNotEmpty) {
      final freq = perfilActivo.frecuenciaRecordatorio > 0 ? perfilActivo.frecuenciaRecordatorio : 10;
      final now = DateTime.now();

      // Programar 5 notificaciones de recordatorio nativo del sistema
      for (int i = 1; i <= 5; i++) {
        final scheduledTime = now.add(Duration(minutes: freq * i));
        NotificationService.programarNotificacion(
          id: i,
          titulo: "🔑 Mission Kids: ¡Alerta de Misiones!",
          cuerpo: "Hola ${perfilActivo.nombre}, tienes ${pendientes.length} misiones pendientes de completar en tu lista. 🚀",
          programacion: scheduledTime,
        );
      }
    }
  }

  void _checkReminders() {
    if (!mounted) return;
    
    final perfilesProv = Provider.of<PerfilesProvider>(context, listen: false);
    final tareaProv = Provider.of<TareaProvider>(context, listen: false);

    if (perfilesProv.isLoading || tareaProv.isLoading) return;

    final now = DateTime.now();
    bool shouldPlaySound = false;
    List<String> mensajes = [];

    for (var perfil in perfilesProv.todosLosPerfiles) {
      final freq = perfil.frecuenciaRecordatorio > 0 ? perfil.frecuenciaRecordatorio : 10;
      
      // Si estamos en el minuto exacto del intervalo...
      if (now.minute % freq == 0) {
        
        // Buscar TODAS las tareas pendientes del bloque actual o bloques anteriores del día
        final pendientes = tareaProv.listaTareasActivas(perfil.id).where((t) {
          if (t.estado != 'pendiente') return false;
          
          final bloques = ['manana', 'tarde', 'noche'];
          final indiceTarea = bloques.indexOf(t.bloque);
          final indiceActual = bloques.indexOf(tareaProv.bloqueActual);
          
          return indiceTarea <= indiceActual; // Actual y atrasadas
        }).toList();

        if (pendientes.isNotEmpty) {
          shouldPlaySound = true;
          mensajes.add("${perfil.nombre}: ${pendientes.length} misiones");
        }
      }
    }

    if (shouldPlaySound) {
      SoundService.playReminder();
      // Usar root scaffold messenger para evitar problemas de contexto
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text("🔔 Recordatorio: ${mensajes.join(" | ")}"),
          backgroundColor: Colors.orange.shade800,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
