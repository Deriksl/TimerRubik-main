import 'package:camera/camera.dart';

class CameraService {
  CameraController? _cameraController;

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.high);
    await _cameraController?.initialize();
  }

  Future<String?> takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return null;
    }

    final XFile file = await _cameraController!.takePicture();
    return file.path;
  }

  void dispose() {
    _cameraController?.dispose();
  }
}