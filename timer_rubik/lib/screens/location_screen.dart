import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:timer_rubik/providers/gps_service.dart';


class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  LocationData? _currentLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    final gpsService = GpsService();
    final location = await gpsService.getCurrentLocation();

    if (location != null) {
      setState(() {
        _currentLocation = location;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicación'),
      ),
      body: Center(
        child: _currentLocation != null
            ? Text(
                'Ubicación: ${_currentLocation!.latitude}, ${_currentLocation!.longitude}',
                style: const TextStyle(fontSize: 16),
              )
            : const Text('Obteniendo ubicación...'),
      ),
    );
  }
}