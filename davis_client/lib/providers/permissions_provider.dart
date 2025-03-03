import 'package:davis_client/models/permissions_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsNotifier extends Notifier<PermissionsState> {
  @override
  PermissionsState build() {
    _requestPermissions();
    return const PermissionsState(
      camera: false,
      microphone: false,
      location: false,
    );
  }

  Future<void> _requestPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final microphoneStatus = await Permission.microphone.request();
    final locationStatus = await Permission.location.request();

    state = PermissionsState(
      camera: cameraStatus.isGranted,
      microphone: microphoneStatus.isGranted,
      location: locationStatus.isGranted,
    );
  }
}

final permissionsProvider =
    NotifierProvider<PermissionsNotifier, PermissionsState>(
      () => PermissionsNotifier(),
    );
