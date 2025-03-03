import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

enum AppSound {
  start('sounds/start.wav', 1.0),
  stop('sounds/stop.wav', 1.0),
  shutter('sounds/shutter.wav', 1.0);

  final String filePath;
  final double volume;

  const AppSound(this.filePath, this.volume);
}

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<void>? _completionSubscription;

  Future<void> playSound(AppSound sound) async {
    await _audioPlayer.setVolume(sound.volume);
    _completionSubscription?.cancel();

    await _audioPlayer.play(AssetSource(sound.filePath));
  }

  Future<void> playFile(String filePath, {Function? onComplete}) async {
    await _audioPlayer.setVolume(1);
    _completionSubscription?.cancel();

    await _audioPlayer.play(DeviceFileSource(filePath));

    _completionSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      onComplete?.call();
    });
  }

  void stopPlayback() {
    _audioPlayer.stop();
  }
}
