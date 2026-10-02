import 'package:flutter/material.dart';
import '../Config/app_config.dart';
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              'No active parcel',
              style: AppText.body.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your current shipment will appear here',
              style: AppText.caption,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
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
                style: AppText.number.copyWith(
                  fontSize: 14,
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
                  style: AppText.body.copyWith(color: Colors.white),
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
                  style: AppText.body.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
                    width: 24,
                    height: 2,
                    color: isDone ? Colors.white : Colors.white30,
                  ),
              ],
            );
          }),
        ),
        const SizedBox(height: 10),
        Text(
          status.name.replaceAll('_', ' ').toUpperCase(),
          style: AppText.caption.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}