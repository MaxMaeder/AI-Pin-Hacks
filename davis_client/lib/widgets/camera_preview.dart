import 'package:davis_client/constants/ui_constants.dart';
import 'package:davis_client/models/camera_state.dart';
import 'package:davis_client/providers/camera_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'dart:io';

class VisionCameraPreview extends ConsumerStatefulWidget {
  @override
  _VisionCameraPreviewState createState() => _VisionCameraPreviewState();
}

class _VisionCameraPreviewState extends ConsumerState<VisionCameraPreview> {
  double _flashOpacity = 0.0;

  void _triggerFlash() {
    setState(() {
      _flashOpacity = 1.0;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _flashOpacity = 0.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraStateProvider);
    final cameraController =
        ref.read(cameraStateProvider.notifier).getController();
    final capturedImage = cameraState.capturedImage;

    ref.listen<CameraState>(cameraStateProvider, (previous, next) {
      if (previous?.capturedImage == null && next.capturedImage != null) {
        _triggerFlash();
      }
    });

    if (!cameraState.isPreviewDisplayed) {
      return SizedBox.shrink();
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), // Rounded corners
            border: Border.all(color: UiConstants.accentColor, width: 5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15), // Fit inside border
            child: AspectRatio(
              aspectRatio: 1, // Square aspect ratio
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (cameraController != null &&
                      cameraController.value.isInitialized)
                    CameraPreview(cameraController),

                  if (capturedImage != null)
                    Image.file(File(capturedImage.path), fit: BoxFit.cover),

                  AnimatedOpacity(
                    opacity: _flashOpacity,
                    duration: const Duration(milliseconds: 100),
                    child: Container(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
