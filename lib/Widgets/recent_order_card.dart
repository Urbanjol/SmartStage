import 'package:flutter/material.dart';
import '../models/parcel_model.dart';

class RecentOrderCard extends StatelessWidget {
  final ParcelModel parcel;

  const RecentOrderCard({Key? key, required this.parcel}) : super(key: key);

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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: Color(0xFF2563EB),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parcel.trackingCode,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${parcel.pickupStage} → ${parcel.destinationStage}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: parcel.status == ParcelStatus.delivered
                  ? const Color(0xFF10B981).withOpacity(0.1)
                  : const Color(0xFFFFB800).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              parcel.statusLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: parcel.status == ParcelStatus.delivered
                    ? const Color(0xFF10B981)
                    : const Color(0xFFFFB800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}