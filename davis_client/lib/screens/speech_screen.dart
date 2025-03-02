import 'package:davis_client/widgets/StatusText.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/speech_provider.dart';

class SpeechScreen extends ConsumerWidget {
  const SpeechScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(speechStateProvider);
    final speechController = ref.read(speechStateProvider.notifier);

    String displayText = "Hold to Speak";
    switch (state) {
      case RecordingState.listening:
        displayText = "Listening...";
        break;
      case RecordingState.thinking:
        displayText = "Thinking...";
        break;
      case RecordingState.responding:
        displayText = "Responding...";
        break;
      case RecordingState.idle:
        displayText = "Hold to Speak";
        break;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: speechController.startRecording,
        onLongPressUp: speechController.stopRecording,
        child: Center(child: StatusText(displayText)),
      ),
    );
  }
}
