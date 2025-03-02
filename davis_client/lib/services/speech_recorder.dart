import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class SpeechRecorder {
  final record = AudioRecorder();
  DateTime? recordingStartTime;
  String? recordedFilePath;

  Future<bool> checkPermission() async {
    return await record.hasPermission();
  }

  Future<void> startRecording() async {
    if (!await checkPermission()) {
      throw Exception("Microphone permission denied");
    }

    final dir = await getTemporaryDirectory();
    recordedFilePath = "${dir.path}/recorded_audio.m4a";
    recordingStartTime = DateTime.now();

    await record.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 32000,
        numChannels: 1,
      ),
      path: recordedFilePath!,
    );
  }

  Future<String?> stopRecording() async {
    if (recordingStartTime == null) return null;

    await record.stop();
    final duration =
        DateTime.now().difference(recordingStartTime!).inMilliseconds;

    if (duration < 1000) {
      return null; // Discard recordings <1s
    }

    return recordedFilePath;
  }
}
