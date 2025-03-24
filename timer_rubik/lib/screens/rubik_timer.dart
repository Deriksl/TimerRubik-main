import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timer_rubik/views/records.dart';
import 'dart:async';
import 'package:timer_rubik/views/scramble.dart';
import 'package:timer_rubik/providers/scramble_providers.dart';
import 'package:timer_rubik/providers/times_providers.dart';
import 'package:camera/camera.dart';
import 'package:location/location.dart';
import 'dart:io';
import 'package:flutter/services.dart'; // Para MethodChannel

class RubikTimer extends StatefulWidget {
  const RubikTimer({super.key});

  @override
  State<RubikTimer> createState() => _RubikTimerState();
}

class _RubikTimerState extends State<RubikTimer> {
  Timer? _timer;
  double _time = 0.0;
  bool _isRunning = false;
  final Utils utils = Utils();
  String _currentScramble = "";

  CameraController? _cameraController;
  String? _imagePath;
  LocationData? _currentLocation;

  final Location _location = Location();
  final MethodChannel _channel = const MethodChannel('com.example.timer_rubik/permissions'); // Canal para permisos

  @override
  void initState() {
    super.initState();
    _generateNewScramble();
    _initializeCamera();
    _getCurrentLocation();
  }

  void _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.high);
    await _cameraController?.initialize();
  }

  Future<bool> _requestCameraPermission() async {
    try {
      final bool isGranted = await _channel.invokeMethod('requestCameraPermission');
      return isGranted;
    } on PlatformException catch (e) {
      print("Error al solicitar permiso de cámara: ${e.message}");
      return false;
    }
  }

  Future<bool> _requestLocationPermission() async {
    try {
      final bool isGranted = await _channel.invokeMethod('requestLocationPermission');
      return isGranted;
    } on PlatformException catch (e) {
      print("Error al solicitar permiso de ubicación: ${e.message}");
      return false;
    }
  }

  void _getCurrentLocation() async {
    if (await _requestLocationPermission()) {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      final location = await _location.getLocation();
      if (mounted) {
        setState(() {
          _currentLocation = location;
        });
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso de ubicación denegado')),
        );
      }
    }
  }

  void _generateNewScramble() {
    setState(() {
      _currentScramble = utils.getScramble();
    });
  }

  void _startTimer() {
    final scrambleProvider = Provider.of<ScrambleProvider>(context, listen: false);
    scrambleProvider.addScramble(_currentScramble);

    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        _time += 0.01;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    final timesProvider = Provider.of<TimesProvider>(context, listen: false);
    _generateNewScramble();
    setState(() {
      _isRunning = false;
      timesProvider.addTime(_time);
      _time = 0.0;
    });
  }

  Future<void> _takePicture() async {
    if (await _requestCameraPermission()) {
      if (_cameraController == null || !_cameraController!.value.isInitialized) {
        return;
      }

      final XFile file = await _cameraController!.takePicture();
      if (mounted) {
        setState(() {
          _imagePath = file.path;
        });
      }

      await _saveImageToGallery(file.path);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso de cámara denegado')),
        );
      }
    }
  }

  Future<void> _saveImageToGallery(String imagePath) async {
    try {
      final bool isSaved = await _channel.invokeMethod('saveImageToGallery', {'path': imagePath});
      if (mounted) {
        if (isSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto guardada en la galería')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al guardar la foto')),
          );
        }
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text(
            _currentScramble,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!_isRunning) {
                  setState(() => _isRunning = true);
                  _startTimer();
                } else {
                  _stopTimer();
                }
              },
              onLongPress: () {
                setState(() => _time = 0.0);
              },
              child: Center(
                child: Text(
                  _time.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 80),
                ),
              ),
            ),
          ),
          const RecordsTimes(),
          if (_imagePath != null)
            Image.file(
              File(_imagePath!),
              height: 100,
              width: 100,
            ),
          ElevatedButton(
            onPressed: _takePicture,
            child: const Text('Tomar Foto'),
          ),
          if (_currentLocation != null)
            Text(
              'Ubicación: ${_currentLocation!.latitude}, ${_currentLocation!.longitude}',
              style: const TextStyle(fontSize: 16),
            ),
          ElevatedButton(
            onPressed: _getCurrentLocation,
            child: const Text('Obtener Ubicación'),
          ),
        ],
      ),
    );
  }
}