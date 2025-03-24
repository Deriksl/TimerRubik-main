import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timer_rubik/views/records.dart';
import 'dart:async';
import 'package:timer_rubik/views/scramble.dart';
import 'package:timer_rubik/providers/scramble_providers.dart';
import 'package:timer_rubik/providers/times_providers.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io'; 

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
  Position? _currentPosition;

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

  void _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    _currentPosition = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
    setState(() {});
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
          if (_currentPosition != null)
            Text(
              'Ubicación: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}',
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