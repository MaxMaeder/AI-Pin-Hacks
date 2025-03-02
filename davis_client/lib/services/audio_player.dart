import 'package:audioplayers/audioplayers.dart';

enum AppSound {
  start('sounds/start.wav', 1.0),
  stop('sounds/stop.wav', 1.0),
  shutter('sounds/shutter.wav', 1.0);

  final String filePath;
  final double volume;

  const AppSound(this.filePath, this.volume);
}

class AppAudioPlayer {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playSound(AppSound sound) async {
    await _audioPlayer.setVolume(sound.volume);
    await _audioPlayer.play(AssetSource(sound.filePath));
  }

  Future<void> playFile(String filePath) async {
    await _audioPlayer.setVolume(1);
    await _audioPlayer.play(DeviceFileSource(filePath));
  }
}
