import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isPlaying = false;

  static Future<void> playReminder() async {
    if (_isPlaying) return;
    
    try {
      _isPlaying = true;
      // Usamos un sonido corto de la librería pública de Google
      await _player.play(UrlSource('https://actions.google.com/sounds/v1/alarms/beep_short.ogg'));
      
      _player.onPlayerComplete.listen((event) {
        _isPlaying = false;
      });
    } catch (e) {
      print("Error playing sound: $e");
      _isPlaying = false;
    }
  }
}
