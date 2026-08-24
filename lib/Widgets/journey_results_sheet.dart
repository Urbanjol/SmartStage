import 'package:flutter/material.dart';
import '../Config/theme.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? SmartStageColors.navyCard : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.only(bottom: 24, top: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: isDark
                  ? SmartStageColors.greyDark
                  : SmartStageColors.greyLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'To: $destination',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isDark
                        ? SmartStageColors.white
                        : SmartStageColors.deepNavy,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: SmartStageColors.electricGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: SmartStageColors.electricGreen.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '${journeys.length} route${journeys.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                      color: SmartStageColors.electricGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

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

  Color _getGlowColor(String space) {
    if (space.contains('Space Available')) {
      return SmartStageColors.electricGreen;
    } else if (space.contains('Filling Up')) {
      return SmartStageColors.orange;
    } else {
      return SmartStageColors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primarySpace =
    journey.legs.isNotEmpty ? journey.legs.first.space : 'Full';
    final glowColor = _getGlowColor(primarySpace);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? SmartStageColors.navyLight : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: index == 0 ? SmartStageColors.gold : glowColor.withOpacity(0.4),
          width: index == 0 ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: index == 0
                ? SmartStageColors.goldGlow
                : glowColor.withOpacity(0.25),
            blurRadius: index == 0 ? 22 : 12,
            spreadRadius: index == 0 ? 1 : 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (index == 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              SmartStageColors.gold,
                              SmartStageColors.softGold,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'FASTEST',
                          style: TextStyle(
                            color: SmartStageColors.deepNavy,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Text(
                      '${journey.totalTimeMin} min',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isDark
                            ? SmartStageColors.white
                            : SmartStageColors.deepNavy,
                      ),
                    ),
                  ],
                ),
                Text(
                  'UGX ${journey.totalFare}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: SmartStageColors.gold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ...journey.legs.asMap().entries.map((entry) {
              final i = entry.key;
              final leg = entry.value;
              final isLast = i == journey.legs.length - 1;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                  ? SmartStageColors.electricGreen
                                  : SmartStageColors.gold,
                              border: Border.all(
                                color: isDark
                                    ? SmartStageColors.navyLight
                                    : Colors.white,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: i == 0
                                      ? SmartStageColors.greenGlow
                                      : SmartStageColors.goldGlow,
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 30,
                              color: isDark
                                  ? SmartStageColors.greyDark
                                  : SmartStageColors.greyLight,
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
                            Text(
                              'Walk ${leg.walkMin} min to ${leg.stage}',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? SmartStageColors.greyMid
                                    : SmartStageColors.greyDark,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: SmartStageColors.deepNavy,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: SmartStageColors.electricGreen
                                        .withOpacity(0.4),
                                  ),
                                ),
                                child: Text(
                                  leg.matatuPlate,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: SmartStageColors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  leg.destination,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: isDark
                                        ? SmartStageColors.white
                                        : SmartStageColors.deepNavy,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _buildInfoChip(
                                  Icons.access_time, leg.departure, isDark),
                              const SizedBox(width: 8),
                              _buildInfoChip(
                                  Icons.flag, leg.arrival, isDark),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _buildSeatStatus(leg.space, glowColor),
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

            GlowButton(
              text: 'BOOK THIS ROUTE',
              color: index == 0
                  ? SmartStageColors.gold
                  : SmartStageColors.electricGreen,
              glowColor: index == 0
                  ? SmartStageColors.goldGlow
                  : SmartStageColors.greenGlow,
              icon: Icons.check_circle_outline,
              onPressed: () {
                // Booking will be implemented later
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatStatus(String space, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.6),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            space,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: isDark
              ? SmartStageColors.greyMid
              : SmartStageColors.greyDark,
        ),
        const SizedBox(width: 2),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: isDark
                ? SmartStageColors.greyMid
                : SmartStageColors.greyDark,
          ),
        ),
      ],
    );
  }
}