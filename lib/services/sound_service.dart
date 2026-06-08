import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isPlaying = false;

  static Future<void> playReminder() async {
    if (_isPlaying) return;
    
    try {
      _isPlaying = true;
      // Reproduce el sonido de alerta de forma local para funcionamiento offline
      await _player.play(AssetSource('sounds/beep_short.ogg'));
      
      _player.onPlayerComplete.listen((event) {
        _isPlaying = false;
      });
    } catch (e) {
      print("Error playing sound: $e");
      _isPlaying = false;
    }
  }
}
