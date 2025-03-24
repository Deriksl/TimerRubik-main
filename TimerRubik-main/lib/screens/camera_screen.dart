import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.high);
    await _cameraController?.initialize();
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    final XFile file = await _cameraController!.takePicture();
    setState(() {
      _imagePath = file.path;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cámara'),
      ),
      body: Column(
        children: [
          if (_cameraController != null && _cameraController!.value.isInitialized)
            CameraPreview(_cameraController!),
          ElevatedButton(
            onPressed: _takePicture,
            child: const Text('Tomar Foto'),
          ),
          if (_imagePath != null)
            Image.file(
              File(_imagePath!),
              height: 100,
              width: 100,
            ),
        ],
      ),
    );
  }
}