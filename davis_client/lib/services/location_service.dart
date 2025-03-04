import 'package:davis_client/models/app_permission.dart';
import 'package:davis_client/util/permission_helper.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Position? _lastKnownPosition;

  Future<void> updateLocation() async {
    if (await isPermissionGranted(AppPermission.location)) {
      _lastKnownPosition = await Geolocator.getCurrentPosition();
    } else {
      _lastKnownPosition = null;
    }
  }

  Position? getLocation() {
    return _lastKnownPosition;
  }
}
