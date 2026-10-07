import 'package:flutter/material.dart';

class CurrentLocationMarker extends StatelessWidget {
  const CurrentLocationMarker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF2563EB),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 4,
          ),
        ],
      ),
    );
  }
}