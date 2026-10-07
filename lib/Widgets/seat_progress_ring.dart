import 'package:flutter/material.dart';
import '../Config/app_config.dart';

class SeatProgressRing extends StatelessWidget {
  final int filled;
  final int total;
  final double size;

  const SeatProgressRing({
    Key? key,
    required this.filled,
    required this.total,
    this.size = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? filled / total : 0.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 5,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF2563EB),
              ),
            ),
          ),
          Text(
            '${(progress * 100).toStringAsFixed(0)}%',
            style: AppText.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2563EB),
            ),
          ),
        ],
      ),
    );
  }
}