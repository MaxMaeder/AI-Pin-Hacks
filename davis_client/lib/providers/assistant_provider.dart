import 'dart:io';

import 'package:davis_client/models/assistant_state.dart';
import 'package:davis_client/models/completion_state.dart';
import 'package:davis_client/providers/app_providers.dart';
import 'package:davis_client/providers/camera_provider.dart';
import 'package:davis_client/services/location_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../services/audio_recorder_service.dart';
import '../services/audio_player_service.dart';
import '../services/backend_service.dart';

class AssistantStateNotifier extends StateNotifier<AssistantState> {
  Ref ref;

  final AudioRecorderService recorder;
  final AudioPlayerService player;
  final LocationService locator;
  final BackendService backend;

  bool _isResponseLoaded = false;

  AssistantStateNotifier(
    this.ref,
    this.recorder,
    this.player,
    this.locator,
    this.backend,
  ) : super(AssistantState(completionState: CompletionState.idle));

  void capturePhoto() {
    if (state.completionState != CompletionState.idle) return;

    try {
      ref.read(cameraStateProvider.notifier).capturePhoto();
    } catch (e) {
      state = state.copyWith(errorMessage: "Error capturing photo: $e");
    }
  }

  Future<void> startRecording() async {
    try {
      state = state.copyWith(completionState: CompletionState.listening);
      await player.playSound(AppSound.start);
      await recorder.startRecording();
      locator.updateLocation();
    } catch (e) {
      state = state.copyWith(
        errorMessage: "Error starting recording: $e",
        completionState: CompletionState.idle,
      );
    }
  }

  Future<void> stopRecording() async {
    try {
      _isResponseLoaded = false;
      state = state.copyWith(completionState: CompletionState.thinking);

      await player.playSound(
        AppSound.stop,
        onComplete: _scheduleLoadingMessage,
      );

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

      Position? curLocation = locator.getLocation();

      File responseAudioFile = await backend.getAssistantResponse(
        audioFile,
        imgFile,
        curLocation,
      );

      _isResponseLoaded = true;
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

  Future<void> _scheduleLoadingMessage() async {
    await Future.delayed(Duration(milliseconds: 500));
    if (_isResponseLoaded) return;

    player.playSound(AppSound.loading);
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
        ref.read(locationServiceProvider),
        ref.read(backendServiceProvider),
      ),
    );
