import 'package:flutter/material.dart';
import '../models/Journey_model.dart';

class JourneyResultsSheet extends StatelessWidget {
  final List<Journey> journeys;
  final String destination;

  const JourneyResultsSheet({
    Key? key,
    required this.journeys,
    required this.destination,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 24, top: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'To: $destination',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${journeys.length} route${journeys.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Journey cards
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: journeys.length,
              itemBuilder: (context, index) {
                return _JourneyCard(journey: journeys[index], index: index);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _JourneyCard extends StatelessWidget {
  final Journey journey;
  final int index;

  const _JourneyCard({required this.journey, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: index == 0 ? const Color(0xFF0056b3) : Colors.grey.shade200,
          width: index == 0 ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row — time and fare
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (index == 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0056b3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'FASTEST',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Text(
                      '${journey.totalTimeMin} min',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Text(
                  'UGX ${journey.totalFare}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF0056b3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Journey legs
            ...journey.legs.asMap().entries.map((entry) {
              final i = entry.key;
              final leg = entry.value;
              final isLast = i == journey.legs.length - 1;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline dots
                    SizedBox(
                      width: 24,
                      child: Column(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i == 0
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF0056b3),
                              border:
                              Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 30,
                              color: Colors.grey.shade200,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Leg details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (leg.walkMin > 0)
                            Text(
                              'Walk ${leg.walkMin} min to ${leg.stage}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.directions_bus,
                                  size: 16, color: Color(0xFF0056b3)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${leg.matatuPlate} → ${leg.destination}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _buildInfoChip(
                                  Icons.access_time, leg.departure),
                              const SizedBox(width: 8),
                              _buildInfoChip(Icons.flag, leg.arrival),
                              const SizedBox(width: 8),
                              _buildInfoChip(
                                  Icons.event_seat, leg.space),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 8),

            // Book button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Booking will be implemented later
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0056b3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Book This Route',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey.shade500),
        const SizedBox(width: 2),
        Text(
          text,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}