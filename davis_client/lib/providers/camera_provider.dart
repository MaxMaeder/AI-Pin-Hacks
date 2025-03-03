import 'package:davis_client/models/camera_state.dart';
import 'package:davis_client/providers/app_providers.dart';
import 'package:davis_client/services/audio_player_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';

class CameraStateNotifier extends StateNotifier<CameraState> {
  final AudioPlayerService player;

  CameraController? _controller;

  CameraStateNotifier(this.player) : super(CameraState());

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _controller = CameraController(
        cameras[0], // Use the back camera
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
    }
  }

  CameraController? getController() {
    return _controller;
  }

  Future<void> capturePhoto() async {
    await _initializeCamera();

    if (_controller == null) return;

    state = state.copyWithoutImg().copyWith(isPreviewDisplayed: true);
    await Future.delayed(Duration(milliseconds: 500));

    state = state.copyWith(capturedImage: await _controller!.takePicture());
    await player.playSound(AppSound.shutter);

    await Future.delayed(Duration(seconds: 1));
    state = state.copyWith(isPreviewDisplayed: false);

    await _disposeCamera();
  }

  void discardPhoto() {
    state = state.copyWithoutImg();
  }

  Future<void> _disposeCamera() async {
    await _controller?.dispose();
    _controller = null;
  }
}

final cameraStateProvider =
    StateNotifierProvider<CameraStateNotifier, CameraState>(
      (ref) => CameraStateNotifier(ref.read(audioPlayerServiceProvider)),
    );
