import 'package:flutter/material.dart';
import '../Config/theme.dart';
import '../Providers/taxi_stream_provider.dart';

void showVehicleInfoSheet(BuildContext context, TaxiVehicle taxi) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: SmartStageColors.greyLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                taxi.icon,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      taxi.plate,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'To: ${taxi.destination}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(
                'Seats: ${taxi.seatsAvailable}',
                Icons.event_seat,
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                taxi.seatState == 'space_available'
                    ? 'Space Available'
                    : taxi.seatState == 'filling_up'
                    ? 'Filling Up'
                    : 'Full',
                taxi.seatState == 'space_available'
                    ? Icons.check_circle
                    : Icons.warning,
              ),
            ],
          ),
          const SizedBox(height: 20),
          GlowButton(
            text: 'SIGNAL THIS TAXI',
            color: SmartStageColors.primaryBlue,
            glowColor: SmartStageColors.primaryBlue.withOpacity(0.4),
            onPressed: () {
              Navigator.pop(context);
              // Signal logic here
            },
          ),
        ],
      ),
    ),
  );
}

Widget _buildInfoChip(String text, IconData icon) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        Icon(icon, size: 14, color: SmartStageColors.primaryBlue),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    ),
  );
}