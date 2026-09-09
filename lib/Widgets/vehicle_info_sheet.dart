import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../Config/theme.dart';
import '../Providers/taxi_stream_provider.dart';
import '../Services/eta_service.dart';

void showVehicleInfoSheet(
    BuildContext context,
    TaxiVehicle taxi, {
      Position? passengerPosition,
    }) {
  String etaText = 'ETA: --';
  String distanceText = '';

  if (passengerPosition != null && taxi.speed > 0) {
    final distance = EtaService.distanceInKm(
      lat1: passengerPosition.latitude,
      lng1: passengerPosition.longitude,
      lat2: taxi.lat,
      lng2: taxi.lng,
    );

    final eta = EtaService.calculateETA(
      distanceKm: distance,
      speedKmh: taxi.speed,
    );

    etaText = 'ETA: ${eta.toStringAsFixed(0)} min';
    distanceText = '${distance.toStringAsFixed(1)} km away';
  } else if (taxi.speed > 0) {
    etaText = 'Speed: ${taxi.speed.toStringAsFixed(0)} km/h';
  }

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
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.schedule,
                size: 16,
                color: SmartStageColors.primaryBlue,
              ),
              const SizedBox(width: 6),
              Text(
                etaText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              if (distanceText.isNotEmpty) ...[
                const Spacer(),
                Text(
                  distanceText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
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