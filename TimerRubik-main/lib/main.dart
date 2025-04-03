import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'package:timer_rubik/providers/bluetooth_service.dart';
import 'package:timer_rubik/widgets/custom_app_bar.dart';
import 'package:timer_rubik/providers/scramble_providers.dart';
import 'package:timer_rubik/providers/times_providers.dart';
import 'package:timer_rubik/screens/onboarding_screen.dart';
import 'package:timer_rubik/views/side_menu.dart';
import 'package:timer_rubik/providers/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimesProvider()),
        ChangeNotifierProvider(create: (_) => ScrambleProvider()),
        Provider(create: (_) => BluetoothService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          drawer: const SideMenu(),
          appBar: const CustomAppBar(),
          body: const OnBoardingScreen(),
        ),
      ),
    );
  }
}