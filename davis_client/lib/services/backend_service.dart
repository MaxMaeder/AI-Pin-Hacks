import 'dart:io';
import 'dart:convert';
import 'package:davis_client/util/device_id.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class BackendService {
  final String apiUrl = "https://glasses.mmaeder.com/api/dev/handle";

  /// Sends recorded audio to the backend and receives processed audio response.
  Future<File> getAssistantResponse(
    File speechFile,
    File? imgFile,
    Position? location,
  ) async {
    List<int> audioBytes = await speechFile.readAsBytes();
    List<int>? imgBytes = await imgFile?.readAsBytes();

    final Map<String, dynamic> metadata = {
      "audioSize": audioBytes.length,
      "audioFormat": "m4a",
      "imageSize": imgBytes?.length ?? 0,
      "deviceId": await getDeviceId(),
      "audioBitrate": "64k",
    };

    if (location != null) {
      metadata["latitude"] = location.latitude;
      metadata["longitude"] = location.longitude;
    }

    final String metadataJson = jsonEncode(metadata);

    // Ensure metadata is 512 bytes (null-terminated & padded)
    List<int> metadataBytes = ascii.encode(metadataJson);
    if (metadataBytes.length > 511) {
      throw Exception("Metadata too large, must be <= 511 bytes");
    }
    metadataBytes = List<int>.from(metadataBytes)..add(0); // Null-terminate
    while (metadataBytes.length < 512) {
      metadataBytes.add(0); // Pad with zeros
    }

    // Combine metadata and audio
    List<int> requestBody = [
      ...metadataBytes,
      ...(imgBytes ?? []),
      ...audioBytes,
    ];

    // Send the request
    var response = await http.post(Uri.parse(apiUrl), body: requestBody);

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
