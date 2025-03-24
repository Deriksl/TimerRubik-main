import 'package:flutter/material.dart';
import 'package:timer_rubik/screens/camera_screen.dart';
import 'package:timer_rubik/screens/location_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      title: const Row(
        children: [
          SizedBox(
            width: 60,
          ),
          Column(
            children: [
              Text(
                'Cubo: 3x3',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black),
              ),
              Text(
                'Normal',
                style: TextStyle(fontSize: 10),
              )
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.camera_alt),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CameraScreen()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.location_on),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LocationScreen()),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}