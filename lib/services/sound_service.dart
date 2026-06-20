import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isPlaying = false;
  static Timer? _timer;

  static Future<void> playReminder() async {
    if (_isPlaying) return;
    
    try {
      _isPlaying = true;
      
      // Cancelar cualquier temporizador previo activo
      _timer?.cancel();
      
      // Configurar modo bucle para prolongar el sonido corto
      await _player.setReleaseMode(ReleaseMode.loop);
      
      // Reproduce el sonido de alerta de forma local para funcionamiento offline
      await _player.play(AssetSource('sounds/beep_short.ogg'));
      
      // Detener automáticamente después de 5 segundos
      _timer = Timer(const Duration(seconds: 5), () async {
        await stopReminder();
      });
    } catch (e) {
      debugPrint("Error playing sound: $e");
      _isPlaying = false;
    }
  }

  static Future<void> stopReminder() async {
    try {
      _timer?.cancel();
      _timer = null;
      await _player.stop();
      // Restaurar el modo release normal por defecto
      await _player.setReleaseMode(ReleaseMode.release);
    } catch (e) {
      debugPrint("Error stopping sound: $e");
    } finally {
      _isPlaying = false;
    }
  }
}

