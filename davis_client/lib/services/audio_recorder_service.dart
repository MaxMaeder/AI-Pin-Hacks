import 'package:davis_client/models/app_permission.dart';
import 'package:davis_client/util/permission_helper.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class AudioRecorderService {
  final record = AudioRecorder();
  DateTime? recordingStartTime;
  String? recordedFilePath;

  Future<void> startRecording() async {
    if (!await isPermissionGranted(AppPermission.microphone)) {
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
