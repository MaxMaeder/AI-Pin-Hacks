import 'package:geolocator/geolocator.dart';

class LocationService {
  Position? _lastKnownPosition;

  Future<void> updateLocation() async {
    _lastKnownPosition = await Geolocator.getCurrentPosition();
  }

  Position? getLocation() {
    return _lastKnownPosition;
  }
}
