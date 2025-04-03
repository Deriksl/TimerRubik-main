import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as blue_plus;
import 'package:provider/provider.dart';
import 'package:timer_rubik/providers/bluetooth_service.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BluetoothService>(context, listen: false).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothService = Provider.of<BluetoothService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Dispositivos Bluetooth')),
      body: Column(
        children: [
          StreamBuilder<bool>(
            stream: bluetoothService.isScanning,
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return ElevatedButton(
                  onPressed: bluetoothService.stopScan,
                  child: const Text('Detener escaneo'),
                );
              } else {
                return ElevatedButton(
                  onPressed: bluetoothService.startScan,
                  child: const Text('Escanear dispositivos'),
                );
              }
            },
          ),
          Expanded(
            child: StreamBuilder<List<blue_plus.ScanResult>>(
              stream: bluetoothService.scanResults,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final device = snapshot.data![index].device;
                      return ListTile(
                        title: Text(device.name),
                        subtitle: Text(device.id.toString()),
                        onTap: () => _connectToDevice(device),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No se encontraron dispositivos'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _connectToDevice(blue_plus.BluetoothDevice device) async {
    try {
      await Provider.of<BluetoothService>(context, listen: false)
          .connectToDevice(device);
      // Aquí podrías navegar a otra pantalla para mostrar los datos recibidos
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al conectar: ${e.toString()}')),
      );
    }
  }
}