import 'package:camera/camera.dart';

class CameraState {
  final bool isPreviewDisplayed;
  final XFile? capturedImage;

  CameraState({this.isPreviewDisplayed = false, this.capturedImage});

  CameraState copyWith({bool? isPreviewDisplayed, XFile? capturedImage}) {
    return CameraState(
      isPreviewDisplayed: isPreviewDisplayed ?? this.isPreviewDisplayed,
      capturedImage: capturedImage ?? this.capturedImage,
    );
  }

  CameraState copyWithoutImg() {
    return CameraState(
      isPreviewDisplayed: this.isPreviewDisplayed,
      capturedImage: null,
    );
  }
}
