import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hive/hive.dart';

class BluetoothService {
  late Box _bluetoothDataBox;

  Future<void> init() async {
    _bluetoothDataBox = await Hive.openBox('bluetooth_data');
  }

  // Usamos directamente FlutterBluePlus en lugar de la instancia
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;
  Stream<bool> get isScanning => FlutterBluePlus.isScanning;

  Future<void> startScan() async {
    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 4),
      // Agrega estos parámetros requeridos en versiones recientes
      androidUsesFineLocation: true,
      removeIfGone: const Duration(seconds: 5),
    );
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect(
      autoConnect: false,
      // Parámetros adicionales recomendados
      timeout: const Duration(seconds: 15),
    );
  }

  Future<void> saveReceivedData(Map<String, dynamic> data) async {
    await _bluetoothDataBox.add(data);
  }

  List<Map<String, dynamic>> getAllData() {
    return _bluetoothDataBox.values.cast<Map<String, dynamic>>().toList();
  }
}