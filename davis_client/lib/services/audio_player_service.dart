import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';

enum AppSound {
  start(['sounds/start.wav'], 1.0),
  stop(['sounds/stop.wav'], 1.0),
  shutter(['sounds/shutter.wav'], 1.0),
  loading([
    'sounds/loading/loading-1.wav',
    'sounds/loading/loading-2.wav',
    'sounds/loading/loading-3.wav',
    'sounds/loading/loading-4.wav',
  ], 1.0);

  final List<String> filePaths;
  final double volume;

  const AppSound(this.filePaths, this.volume);

  String getFilePath() {
    final random = Random();
    return filePaths[random.nextInt(filePaths.length)];
  }
}

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<void>? _completionSubscription;

  Future<void> playSound(AppSound sound, {Function? onComplete}) async {
    await _audioPlayer.setVolume(sound.volume);
    _completionSubscription?.cancel();

    await _audioPlayer.play(AssetSource(sound.getFilePath()));

    _completionSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      onComplete?.call();
    });
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
