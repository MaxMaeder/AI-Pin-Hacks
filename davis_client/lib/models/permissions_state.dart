class PermissionsState {
  final bool camera;
  final bool microphone;
  final bool location;

  const PermissionsState({
    required this.camera,
    required this.microphone,
    required this.location,
  });

  PermissionsState copyWith({bool? camera, bool? microphone, bool? location}) {
    return PermissionsState(
      camera: camera ?? this.camera,
      microphone: microphone ?? this.microphone,
      location: location ?? this.location,
    );
  }
}
