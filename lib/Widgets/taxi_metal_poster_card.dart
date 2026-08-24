import 'package:flutter/material.dart';
import '../Config/theme.dart';

class TaxiMetalPosterCard extends StatelessWidget {
  final String stageDeparture;
  final String destination;
  final String fare;
  final int loadedSeats;
  final int totalSeats;

  const TaxiMetalPosterCard({
    Key? key,
    this.stageDeparture = "OLD TAXI PARK (JINJA STAGE)",
    this.destination = "JINJA EXPRESS",
    this.fare = "UGX 15,000",
    this.loadedSeats = 11,
    this.totalSeats = 14,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final seatsLeft = totalSeats - loadedSeats;

    String seatState;
    Color glowColor;

    if (seatsLeft >= 4) {
      seatState = "SPACE AVAILABLE";
      glowColor = SmartStageColors.electricGreen;
    } else if (seatsLeft >= 1) {
      seatState = "FILLING UP";
      glowColor = SmartStageColors.orange;
    } else {
      seatState = "FULL";
      glowColor = SmartStageColors.red;
    }

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: isDark
            ? SmartStageColors.navyCard.withOpacity(0.95)
            : SmartStageColors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: glowColor.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.3),
            blurRadius: 18,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Route
            Row(
              children: [
                Expanded(
                  child: Text(
                    stageDeparture.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? SmartStageColors.greyMid
                          : SmartStageColors.greyDark,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 12,
                    color: SmartStageColors.gold,
                  ),
                ),
                Expanded(
                  child: Text(
                    destination.toUpperCase(),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: isDark
                          ? SmartStageColors.white
                          : SmartStageColors.deepNavy,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Seat status
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: glowColor,
                    boxShadow: [
                      BoxShadow(
                        color: glowColor.withOpacity(0.6),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  seatState,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: glowColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Text(
                  "$loadedSeats/$totalSeats SEATS",
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? SmartStageColors.greyMid
                        : SmartStageColors.greyDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Fare and Escrow
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  fare,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: SmartStageColors.gold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? SmartStageColors.deepNavy
                        : SmartStageColors.deepNavy,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.gpp_good,
                        color: SmartStageColors.electricGreen,
                        size: 11,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "ESCROW",
                        style: TextStyle(
                          color: SmartStageColors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}