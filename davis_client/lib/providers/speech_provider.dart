import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/speech_recorder.dart';
import '../services/audio_player.dart';
import '../services/speech_service.dart';

enum RecordingState { idle, listening, thinking, responding }

class SpeechStateNotifier extends StateNotifier<RecordingState> {
  final SpeechRecorder recorder;
  final AppAudioPlayer player;
  final SpeechService service;

  SpeechStateNotifier(this.recorder, this.player, this.service)
    : super(RecordingState.idle);

  Future<void> startRecording() async {
    state = RecordingState.listening;
    await player.playSound(AppSound.start);
    await recorder.startRecording();
  }

  Future<void> stopRecording() async {
    state = RecordingState.thinking;
    await player.playSound(AppSound.stop);

    String? filePath = await recorder.stopRecording();
    if (filePath == null) {
      state = RecordingState.idle; // Discard short recordings
      return;
    }
    //await Future.delayed(Duration(seconds: 2));

    File processedFile = await service.sendAudioToBackend(filePath);
    state = RecordingState.responding;
    await player.playFile(processedFile.path);
    // await player.playFile(filePath);

    state = RecordingState.idle;
  }
}

final speechStateProvider =
    StateNotifierProvider<SpeechStateNotifier, RecordingState>(
      (ref) => SpeechStateNotifier(
        SpeechRecorder(),
        AppAudioPlayer(),
        SpeechService(),
      ),
    );
