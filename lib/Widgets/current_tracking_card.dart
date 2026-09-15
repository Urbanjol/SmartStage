import 'package:flutter/material.dart';
import '../models/parcel_model.dart';

class CurrentTrackingCard extends StatelessWidget {
  final ParcelModel? parcel;

  const CurrentTrackingCard({Key? key, required this.parcel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (parcel == null) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            const Text(
              'No active parcel',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Your current shipment will appear here',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_2, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                parcel!.trackingCode,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  parcel!.pickupStage,
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.flag_outlined,
                  color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  parcel!.destinationStage,
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTimeline(parcel!.status),
        ],
      ),
    );
  }

  Widget _buildTimeline(ParcelStatus status) {
    final stages = [
      ParcelStatus.created,
      ParcelStatus.picked_up,
      ParcelStatus.in_transit,
      ParcelStatus.near_destination,
      ParcelStatus.delivered,
    ];

    final currentIndex = stages.indexOf(status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(stages.length, (index) {
            final isDone = index <= currentIndex;
            return Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone ? Colors.white : Colors.white30,
                  ),
                ),
                if (index < stages.length - 1)
                  Container(
                    width: 20,
                    height: 2,
                    color: isDone ? Colors.white : Colors.white30,
                  ),
              ],
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          status.name.replaceAll('_', ' ').toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}