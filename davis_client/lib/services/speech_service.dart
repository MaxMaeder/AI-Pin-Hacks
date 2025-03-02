import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class SpeechService {
  final String apiUrl = "https://glasses.mmaeder.com/api/dev/handle";

  /// Sends recorded audio to the backend and receives processed audio response.
  Future<File> sendAudioToBackend(String filePath) async {
    // Convert to GSM format
    File? speechFile = File(filePath);

    List<int> audioBytes = await speechFile.readAsBytes();
    print(audioBytes.length);

    final String metadataJson = jsonEncode({
      "audioSize": audioBytes.length,
      "audioFormat": "m4a",
      "imageSize": 0,
      "deviceId": "test_device",
    });

    // Ensure metadata is 512 bytes (null-terminated & padded)
    List<int> metadataBytes = ascii.encode(metadataJson);
    if (metadataBytes.length > 511) {
      throw Exception("Metadata too large, must be <= 511 bytes");
    }
    metadataBytes = List<int>.from(metadataBytes)..add(0); // Null-terminate
    while (metadataBytes.length < 512) {
      metadataBytes.add(0); // Pad with zeros
    }

    // Read the audio file bytes

    // Combine metadata and audio
    List<int> requestBody = [...metadataBytes, ...audioBytes];

    // Send the request
    var response = await http.post(
      Uri.parse(apiUrl),
      // headers: {"Content-Type": "application/octet-stream"},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      List<int> responseBytes = response.bodyBytes;

      if (responseBytes.length <= 512) {
        throw Exception("Invalid response, too short.");
      }

      // Remove the first 512 bytes (metadata)
      List<int> audioResponse = responseBytes.sublist(512);

      return await _saveProcessedAudio(audioResponse);
    } else {
      throw Exception("Failed to process audio: ${response.statusCode}");
    }
  }

  /// Saves received MP3 response audio.
  Future<File> _saveProcessedAudio(List<int> bytes) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/processed_audio.mp3');
    await file.writeAsBytes(bytes);
    return file;
  }
}
