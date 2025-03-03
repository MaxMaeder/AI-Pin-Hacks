import 'dart:io';

import 'package:davis_client/models/assistant_state.dart';
import 'package:davis_client/models/completion_state.dart';
import 'package:davis_client/providers/app_providers.dart';
import 'package:davis_client/providers/camera_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio_recorder_service.dart';
import '../services/audio_player_service.dart';
import '../services/backend_service.dart';

class AssistantStateNotifier extends StateNotifier<AssistantState> {
  Ref ref;

  final AudioRecorderService recorder;
  final AudioPlayerService player;
  final BackendService backend;

  AssistantStateNotifier(this.ref, this.recorder, this.player, this.backend)
    : super(AssistantState(completionState: CompletionState.idle));

  void capturePhoto() {
    if (state.completionState != CompletionState.idle) return;

    ref.read(cameraStateProvider.notifier).capturePhoto();
  }

  Future<void> startRecording() async {
    try {
      state = state.copyWith(completionState: CompletionState.listening);
      await player.playSound(AppSound.start);
      await recorder.startRecording();
    } catch (e) {
      state = state.copyWith(
        errorMessage: "Error starting recording: $e",
        completionState: CompletionState.idle,
      );
    }
  }

  Future<void> stopRecording() async {
    try {
      state = state.copyWith(completionState: CompletionState.thinking);
      await player.playSound(AppSound.stop);

      String? audioFilePath = await recorder.stopRecording();
      if (audioFilePath == null) {
        state = state.copyWith(completionState: CompletionState.idle);
        return;
      }
      File audioFile = File(audioFilePath);

      File? imgFile;
      final capturedImage = ref.read(cameraStateProvider).capturedImage;
      if (capturedImage != null) {
        imgFile = File(capturedImage.path);
      }

      File responseAudioFile = await backend.getAssistantResponse(
        audioFile,
        imgFile,
      );
      state = state.copyWith(completionState: CompletionState.responding);

      ref.read(cameraStateProvider.notifier).discardPhoto();

      await player.playFile(
        responseAudioFile.path,
        onComplete: () {
          state = state.copyWith(completionState: CompletionState.idle);
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: "Error processing recording: $e",
        completionState: CompletionState.idle,
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void cancelPlayback() {
    if (state.completionState == CompletionState.responding) {
      player.stopPlayback();
      state = state.copyWith(completionState: CompletionState.idle);
    }
  }
}

final assistantStateProvider =
    StateNotifierProvider<AssistantStateNotifier, AssistantState>(
      (ref) => AssistantStateNotifier(
        ref,
        ref.read(audioRecorderProvider),
        ref.read(audioPlayerServiceProvider),
        ref.read(backendServiceProvider),
      ),
    );
