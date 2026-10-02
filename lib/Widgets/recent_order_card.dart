import 'package:flutter/material.dart';
import '../Config/app_config.dart';
import '../models/parcel_model.dart';

class RecentOrderCard extends StatelessWidget {
  final ParcelModel parcel;

  const RecentOrderCard({Key? key, required this.parcel}) : super(key: key);

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
              borderRadius: BorderRadius.circular(12),
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
                  style: AppText.number.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '${parcel.pickupStage} → ${parcel.destinationStage}',
                  style: AppText.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: parcel.status == ParcelStatus.delivered
                  ? const Color(0xFF10B981).withOpacity(0.1)
                  : const Color(0xFFFFB800).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              parcel.statusLabel,
              style: AppText.caption.copyWith(
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