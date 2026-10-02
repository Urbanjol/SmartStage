import 'package:flutter/material.dart';
import '../Config/app_config.dart';

class NearbyDriverCard extends StatelessWidget {
  final String plate;
  final String driverName;
  final String phone;
  final String destination;
  final VoidCallback onMessage;
  final VoidCallback onCall;

  const NearbyDriverCard({
    Key? key,
    required this.plate,
    required this.driverName,
    required this.phone,
    required this.destination,
    required this.onMessage,
    required this.onCall,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_bus,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$driverName • $plate',
                  style: AppText.body.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'To: $destination',
                  style: AppText.caption,
                ),
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: AppText.caption.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.message, color: Color(0xFF2563EB)),
            onPressed: onMessage,
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Color(0xFF10B981)),
            onPressed: onCall,
          ),
        ],
      ),
    );
  }
}