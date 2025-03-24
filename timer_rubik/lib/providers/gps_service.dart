import 'package:location/location.dart';

class GpsService {
  final Location _location = Location();

  Future<LocationData?> getCurrentLocation() async {
    // Verifica si el servicio de ubicación está habilitado
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    // Verifica los permisos de ubicación
    PermissionStatus permissionStatus = await _location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await _location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        return null;
      }
    }

    // Obtiene la ubicación actual
    return await _location.getLocation();
  }
}