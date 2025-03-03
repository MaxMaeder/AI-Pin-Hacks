import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

Future<String> getDeviceId() async {
  const storage = FlutterSecureStorage();
  String? deviceId = await storage.read(key: "device_id");

  if (deviceId == null) {
    deviceId = const Uuid().v4(); // Generate a UUID
    await storage.write(key: "device_id", value: deviceId);
  }

  return deviceId;
}
