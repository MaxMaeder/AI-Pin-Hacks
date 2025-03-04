import 'package:davis_client/models/completion_state.dart';
import 'package:davis_client/providers/assistant_provider.dart';
import 'package:davis_client/providers/camera_provider.dart';
import 'package:davis_client/providers/permissions_provider.dart';
import 'package:davis_client/widgets/status_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CompletionStatus extends ConsumerWidget {
  const CompletionStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assistantState = ref.watch(assistantStateProvider);
    final cameraState = ref.watch(cameraStateProvider);
    final permissionsState = ref.watch(permissionsStateProvider);

    _CompletionStatusText statusText;
    switch (assistantState.completionState) {
      case CompletionState.idle:
        if (!permissionsState.microphone) {
          statusText = _CompletionStatusText(
            message: "Mic Disabled",
            disabled: true,
          );
        } else {
          statusText = _CompletionStatusText(
            message: "Hold to Speak",
            details:
                permissionsState.camera
                    ? (cameraState.capturedImage != null
                        ? "Image captured; vision in use."
                        : "Or, to use vision, tap.")
                    : null,
          );
        }

      case CompletionState.listening:
        statusText = _CompletionStatusText(message: "Listening...");
      case CompletionState.thinking:
        statusText = _CompletionStatusText(message: "Thinking...");
      case CompletionState.responding:
        statusText = _CompletionStatusText(
          message: "Responding...",
          details: "Tap to cancel.",
        );
    }

    return StatusText(
      message: statusText.message,
      details: statusText.details,
      disabled: statusText.disabled,
    );
  }
}

class _CompletionStatusText {
  final String message;
  final String? details;
  final bool disabled;

  _CompletionStatusText({
    required this.message,
    this.details,
    this.disabled = false,
  });
}
