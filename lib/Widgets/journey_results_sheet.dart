import 'package:flutter/material.dart';
import '../Config/app_config.dart';
import '../models/Journey_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class JourneyResultsSheet extends StatefulWidget {
  final List<Journey> journeys;
  final String destination;

  const JourneyResultsSheet({
    Key? key,
    required this.journeys,
    required this.destination,
  }) : super(key: key);

  @override
  State<JourneyResultsSheet> createState() => _JourneyResultsSheetState();
}

class _JourneyResultsSheetState extends State<JourneyResultsSheet> {
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadDestinationPhoto();
  }

  Future<void> _loadDestinationPhoto() async {
    final apiKey = "AIzaSyAFzb2gSE1rAofZCW01N3bAm4BIA1fdgHc";

    try {
      final searchResponse = await http.get(
        Uri.parse(
          'https://maps.googleapis.com/maps/api/place/textsearch/json?query=${widget.destination},Uganda&key=$apiKey',
        ),
      );

      final searchData = jsonDecode(searchResponse.body);

      if (searchData['results'] != null &&
          searchData['results'].isNotEmpty) {
        final place = searchData['results'][0];

        if (place['photos'] != null && place['photos'].isNotEmpty) {
          final photoRef = place['photos'][0]['photo_reference'];
          setState(() {
            _photoUrl =
            'https://maps.googleapis.com/maps/api/place/photo?maxwidth=600&photoreference=$photoRef&key=$apiKey';
          });
        }
      }
    } catch (e) {
      // Silently fail
    }
  }

  @override
  Widget build(BuildContext context) {
    final destination = widget.destination;
    final journeys = widget.journeys;
    final photoUrl = _photoUrl ?? '';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
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
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Destination photo
          if (photoUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(photoUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'To: $destination',
                        style: AppText.header.copyWith(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          if (photoUrl.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    'To: $destination',
                    style: AppText.header.copyWith(fontSize: 16),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Routes count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  '${journeys.length} ${journeys.length == 1 ? 'route' : 'routes'}',
                  style: AppText.title,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Journey list
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: journeys.length,
              itemBuilder: (context, index) {
                return _JourneyCard(
                  journey: journeys[index],
                  index: index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// JOURNEY CARD
// ============================================================
class _JourneyCard extends StatelessWidget {
  final Journey journey;
  final int index;

  const _JourneyCard({required this.journey, required this.index});

  Color _getSeatColor(String space) {
    if (space.contains('Space Available')) {
      return const Color(0xFF10B981);
    } else if (space.contains('Filling Up')) {
      return const Color(0xFFFFB800);
    } else {
      return const Color(0xFFEF4444);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primarySpace =
    journey.legs.isNotEmpty ? journey.legs.first.space : 'Full';
    final seatColor = _getSeatColor(primarySpace);
    final isFastest = index == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFastest
              ? const Color(0xFF2563EB)
              : const Color(0xFFF1F5F9),
          width: isFastest ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                if (isFastest)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'FASTEST',
                      style: AppText.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        fontSize: 10,
                      ),
                    ),
                  ),
                if (isFastest) const SizedBox(width: 8),
                Text(
                  '${journey.totalTimeMin} min',
                  style: AppText.number.copyWith(fontSize: 18),
                ),
                const Spacer(),
                Text(
                  'UGX ${journey.totalFare}',
                  style: AppText.number.copyWith(
                    fontSize: 18,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Divider(
              height: 1,
              color: const Color(0xFFF1F5F9),
              thickness: 1,
            ),

            const SizedBox(height: 12),

            // Legs
            ...journey.legs.asMap().entries.map((entry) {
              final i = entry.key;
              final leg = entry.value;
              final isLast = i == journey.legs.length - 1;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 20,
                      child: Column(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF2563EB),
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 30,
                              color: const Color(0xFFF1F5F9),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (leg.walkMin > 0)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                'Walk ${leg.walkMin} min to ${leg.stage}',
                                style: AppText.caption,
                              ),
                            ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F7FA),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      leg.vehicleIcon,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      leg.matatuPlate,
                                      style: AppText.caption.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1E293B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  leg.destination,
                                  style: AppText.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _buildInfoChip(
                                  Icons.access_time, leg.departure),
                              const SizedBox(width: 12),
                              _buildInfoChip(Icons.flag, leg.arrival),
                            ],
                          ),
                          const SizedBox(height: 6),
                          _buildSeatPill(leg.space, seatColor),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 4),

            // Select button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Booking logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'SELECT THIS ROUTE',
                  style: AppText.body.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatPill(String space, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            space,
            style: AppText.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: const Color(0xFF94A3B8),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppText.caption.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}