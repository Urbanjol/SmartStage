import 'package:flutter/material.dart';
import '../Config/theme.dart';

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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: SmartStageColors.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_bus,
              color: SmartStageColors.primaryBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$driverName • $plate',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'To: $destination',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.message, color: SmartStageColors.primaryBlue),
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