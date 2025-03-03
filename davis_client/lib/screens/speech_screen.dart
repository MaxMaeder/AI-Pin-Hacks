import 'package:davis_client/models/completion_state.dart';
import 'package:davis_client/widgets/camera_preview.dart';
import 'package:davis_client/widgets/error_snackbar.dart';
import 'package:davis_client/widgets/status_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/assistant_provider.dart';

class SpeechScreen extends ConsumerWidget {
  const SpeechScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateNotifier = ref.watch(assistantStateProvider.notifier);
    final state = ref.watch(assistantStateProvider);

    ref.listen(assistantStateProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(ErrorSnackbar.show(next.errorMessage!));
        stateNotifier.clearError();
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: stateNotifier.startRecording,
        onLongPressUp: stateNotifier.stopRecording,
        onTap: () {
          if (state.completionState == CompletionState.idle) {
            stateNotifier.capturePhoto();
          } else {
            stateNotifier.cancelPlayback();
          }
        },
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              StatusText(
                message: state.completionState.message,
                details: state.completionState.details,
              ),
              VisionCameraPreview(),
            ],
          ),
        ),
      ),
    );
  }
}
