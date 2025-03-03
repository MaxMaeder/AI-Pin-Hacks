import 'package:davis_client/services/audio_player_service.dart';
import 'package:davis_client/services/audio_recorder_service.dart';
import 'package:davis_client/services/backend_service.dart';
import 'package:davis_client/services/location_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioRecorderProvider = Provider<AudioRecorderService>(
  (ref) => AudioRecorderService(),
);
final audioPlayerServiceProvider = Provider<AudioPlayerService>(
  (ref) => AudioPlayerService(),
);
final locationServiceProvider = Provider<LocationService>(
  (ref) => LocationService(),
);
final backendServiceProvider = Provider<BackendService>(
  (ref) => BackendService(),
);
