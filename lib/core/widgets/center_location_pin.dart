import 'package:flutter/material.dart';

class CenterLocationPin extends StatelessWidget {
  const CenterLocationPin({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: 40),
          child: Icon(
            Icons.location_pin,
            color: Colors.red,
            size: 60,
          ),
        ),
      ),
    );
  }
}