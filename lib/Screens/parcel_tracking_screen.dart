import 'dart:developer';

import 'package:flutter/material.dart';

class ParcelTrackingScreen extends StatefulWidget {
  const ParcelTrackingScreen({Key? key}) : super(key: key);

  @override
  State<ParcelTrackingScreen> createState() => _ParcelTrackingScreenState();
}

class _ParcelTrackingScreenState extends State<ParcelTrackingScreen> {
  final _waybillController = TextEditingController(text: "ST-MKN-9842X");

  // Current active tracking step (0 = Lodged, 1 = Dispatched/In Transit, 2 = Arrived, 3 = Released)
  final int _currentActiveMilestone = 1;

  @override
  void dispose() {
    _waybillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Core Identity Colors
    const primaryColor = Color(0xFF0056b3);
    const accentGreen = Color(0xFF10B981);

    // Theme Adaptors
    final surfaceColor = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey.shade50;
    final borderColor = isDarkMode ? Colors.white12 : Colors.grey.shade100;
    final headingTextColor = isDarkMode ? Colors.white : Colors.black87;
    final bodyTextColor = isDarkMode ? Colors.white70 : Colors.grey.shade600;

    // Milestone Steps Definition
    final trackingMilestones = [
      {
        "title": "Package Lodged",
        "subtitle": "Kampala Old Taxi Park Stage",
        "time": "10:15 AM",
        "description": "Parcel verified by conductor. Escrow holding deposit locked via SmartStage Ledger nodes."
      },
      {
        "title": "En-Route Transit Dispatched",
        "subtitle": "Matatu Reg: UBL 420K",
        "time": "11:02 AM",
        "description": "Vehicle passed Mukono-Jinji Road checkpoint. Live location stream active via driver node GPS."
      },
      {
        "title": "Arrival at Destination Stage",
        "subtitle": "Jinja Main Terminal Hub",
        "time": "Pending",
        "description": "Awaiting vehicle check-in signature protocol at the target stage offloading lane."
      },
      {
        "title": "Disbursed & Released",
        "subtitle": "Secure Handshake PIN Verified",
        "time": "Pending",
        "description": "Upon arrival, receiver provides secure claim code to unlock funds release token to transit crew."
      }
    ];

    return Scaffold(
        backgroundColor: surfaceColor,
        appBar: AppBar(
          title: const Text("Escrow Parcel Logistics", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          backgroundColor: surfaceColor,
          foregroundColor: headingTextColor,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          // 1. SEARCH/WAYBILL CARD OVERLAY
          Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.all(12),
                  child: const Icon(Icons.local_shipping_outlined, color: primaryColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Waybill Manifest Identifier", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: bodyTextColor, letterSpacing: 0.5)),
                      TextField(
                        controller: _waybillController,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: headingTextColor),
                        decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.only(top: 4)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner, color: primaryColor),
                  onPressed: () {},
                )
              ],
            ),
          ),
        ),

        // 2. LIVE ROUTE TRANSIT PREVIEW BOX
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primaryColor.withOpacity(0.15)),
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.flash_on, color: accentGreen, size: 16),
                          const SizedBox(width: 6),
                          Text("LIVE PIPELINE TRACKING", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: accentGreen, letterSpacing: 0.8)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text("Passing Lugazi Sector", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: headingTextColor)),
                      const SizedBox(height: 4),
                      Text("ETA to Jinja Stage: ~28 Mins", style: TextStyle(fontSize: 13, color: bodyTextColor, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                // Visual decorative map radar token
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(width: 50, height: 50, decoration: BoxDecoration(shape: BoxShape.circle, color: primaryColor.withOpacity(0.15))),
                    const Icon(Icons.navigation, color: primaryColor, size: 24),
                  ],
                )
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // 3. JUMIA STYLE MILESTONE LINEAR TIMELINE
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text("Delivery Milestones Flow", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: headingTextColor)),
        ),
        const SizedBox(height: 16),

                // 3. NATIVE FLUTTER MILESTONE LINEAR TIMELINE
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(trackingMilestones.length, (index) {
                      final milestone = trackingMilestones[index];

                      // Determine state alignment colors
                      final isDone = index <= _currentActiveMilestone;
                      final isCurrent = index == _currentActiveMilestone;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left structural axis timeline node lane
                          Column(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isCurrent
                                      ? accentGreen
                                      : (isDone ? primaryColor : Colors.grey.shade300),
                                  border: isCurrent
                                      ? Border.all(color: Colors.white, width: 3)
                                      : null,
                                  boxShadow: isCurrent ? [
                                    BoxShadow(color: accentGreen.withOpacity(0.4), blurRadius: 8, spreadRadius: 2)
                                  ] : null,
                                ),
                              ),
                              if (index != trackingMilestones.length - 1)
                                Container(
                                  width: 2,
                                  height: 50,
                                  color: isDone ? primaryColor.withOpacity(0.5) : Colors.grey.shade200,
                                ),
                            ],
                          ),

                          const SizedBox(width: 16),

                          // Right description details stack cards
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      milestone["title"]!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isDone ? headingTextColor : headingTextColor.withOpacity(0.4),
                                      ),
                                    ),
                                    Text(
                                      milestone["time"]!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isCurrent ? accentGreen : bodyTextColor.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  milestone["description"]!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDone ? bodyTextColor : bodyTextColor.withOpacity(0.4),
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
        const SizedBox(height: 24),

    // 4. SECURE ESCROW HANDSHAKE DEPOSIT CLAIM PANEL
    Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Container(
    decoration: BoxDecoration(
    gradient: LinearGradient(colors: [primaryColor, primaryColor.withOpacity(0.85)]),
    borderRadius: BorderRadius.circular(20),
    ),
    padding: const EdgeInsets.all(20),
    child: Row(
    children: [
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    const Text("Secure Claim Handshake PIN", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
    const SizedBox(height: 6),
    const Text("PIN: 7740", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2)),
    const SizedBox(height: 6),
    Text("Share this securely with the receiver in Jinja. Conductor needs it to unlock release.", style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11, height: 1.4)),
    ],
    ),
    ),
    Container(
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
    padding: const EdgeInsets.all(12),
    child: const Icon(Icons.vpn_key_outlined, color: Colors.white, size: 24),
    )
    ],
    ),
    ),
    ),
    const SizedBox(height: 40),
    ],
    ),
    ),
    );
  }
}