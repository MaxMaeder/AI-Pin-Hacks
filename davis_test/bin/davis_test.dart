import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> sendAudio(String filePath) async {
  final String apiUrl =
      "https://glasses.mmaeder.com/api/dev/handle"; // Local server

  File speechFile = File(filePath);
  if (!await speechFile.exists()) {
    print("File not found: $filePath");
    return;
  }

  List<int> audioBytes = await speechFile.readAsBytes();
  print("Audio file size: ${audioBytes.length} bytes");

  final String metadataJson = jsonEncode({
    "audioSize": audioBytes.length,
    "audioFormat": "m4a",
    "imageSize": 0,
    "deviceId": "test_device",
  });

  List<int> metadataBytes = ascii.encode(metadataJson);
  if (metadataBytes.length > 511) {
    throw Exception("Metadata too large, must be <= 511 bytes");
  }
  metadataBytes = List<int>.from(metadataBytes)..add(0);
  while (metadataBytes.length < 512) {
    metadataBytes.add(0);
  }

  List<int> requestBody = [...metadataBytes, ...audioBytes];

  try {
    var response = await http.post(Uri.parse(apiUrl), body: requestBody);

    if (response.statusCode == 200) {
      List<int> responseBytes = response.bodyBytes;
      if (responseBytes.length <= 512) {
        throw Exception("Invalid response, too short.");
      }

      List<int> audioResponse = responseBytes.sublist(512);
      File outputFile = File('received_response.mp3');
      await outputFile.writeAsBytes(audioResponse);
      print("Processed audio saved as ${outputFile.path}");
    } else {
      print("Server error: ${response.statusCode}");
    }
  } catch (e) {
    print("Error: $e");
  }
}

void main() {
  sendAudio('sample.m4a');
}
