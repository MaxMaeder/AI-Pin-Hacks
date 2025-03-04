import 'package:davis_client/models/app_permission.dart';
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

  Future<bool> isPermissionGranted(AppPermission permission) async {
    late PermissionStatus status;

    switch (permission) {
      case AppPermission.camera:
        status = await Permission.camera.request();
        state = state.copyWith(camera: status.isGranted);
        break;
      case AppPermission.microphone:
        status = await Permission.microphone.request();
        state = state.copyWith(microphone: status.isGranted);
        break;
      case AppPermission.location:
        status = await Permission.location.request();
        state = state.copyWith(location: status.isGranted);
        break;
    }

    return status.isGranted;
  }
}

final permissionsStateProvider =
    NotifierProvider<PermissionsNotifier, PermissionsState>(
      () => PermissionsNotifier(),
    );
