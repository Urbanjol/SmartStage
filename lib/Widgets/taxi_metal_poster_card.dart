import 'package:flutter/material.dart';

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
    final seatsLeft = totalSeats - loadedSeats;
    final conductorCall = seatsLeft == 1 ? "Omuntu omu yekka!" : "Abantu $seatsLeft bokka!";

    return Container(
      // 🟢 Make it take available screen horizontal breathing space safely
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: MediaQuery.of(context).size.width - 40,
      decoration: BoxDecoration(
        color: const Color(0xFFFBBF24), // Kampala Stage Yellow
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF1E293B), width: 3),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Stack(
        children: [
          // Corner Pop-Rivets
          _buildRivet(top: 6, left: 6),
          _buildRivet(top: 6, right: 6),
          _buildRivet(bottom: 6, left: 6),
          _buildRivet(bottom: 6, right: 6),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  stageDeparture.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'Courier', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 8),

                // Center Route Graphic Frame
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: const BoxDecoration(
                    border: Border.symmetric(horizontal: BorderSide(color: Color(0xFF1E293B), width: 2)),
                  ),
                  child: Text(
                    destination.toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1.5),
                  ),
                ),
                const SizedBox(height: 12),

                // Lower Metadata Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 🟢 Safety Wrap: Forces the text components horizontally without overflow blocks
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("FARE: $fare", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                          const SizedBox(height: 2),
                          Text(
                            "$loadedSeats/$totalSeats SEATS • \"$conductorCall\"",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFB45309)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(2)),
                      child: const Row(
                        children: [
                          Icon(Icons.gpp_good, color: Color(0xFF10B981), size: 12),
                          SizedBox(width: 4),
                          Text("ESCROW", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRivet({double? top, double? bottom, double? left, double? right}) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: 6, height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF64748B),
          border: Border.all(color: const Color(0xFF1E293B), width: 1),
        ),
      ),
    );
  }
}