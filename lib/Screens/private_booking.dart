import 'package:flutter/material.dart';
import '../Screens/parcel_tracking_screen.dart';

class PrivateHireScreen extends StatefulWidget {
  const PrivateHireScreen({Key? key}) : super(key: key);

  @override
  State<PrivateHireScreen> createState() => _PrivateHireScreenState();
}

class _PrivateHireScreenState extends State<PrivateHireScreen> {
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  String _selectedVehicleClass = "Drone Van";
  int _passengerCount = 14;

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //dark mode logic
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xFF0056b3);
    const accentGreen = Color(0xFF10B981);
    // Dynamic Surface & Text Layers
    final surfaceColor = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey.shade50;
    final borderColor = isDarkMode ? Colors.white12 : Colors.grey.shade100;
    final headingTextColor = isDarkMode ? Colors.white : Colors.black87;
    final bodyTextColor = isDarkMode ? Colors.white70 : Colors.grey.shade600;

    final featuredEvents = [
      {
        "title": "Cranes vs. Ivory Coast",
        "location": "Namboole Stadium",
        "date": "Friday, 4:00 PM",
        "escrowDeposit": "UGX 45,000",
        "image": "https://images.unsplash.com/photo-1508098682722-e99c43a406b2?auto=format&fit=crop&w=500&q=80",
      },
      {
        "title": "Blankets & Wine Kampala",
        "location": "Lugogo Cricket Oval",
        "date": "Sunday, 12:00 PM",
        "escrowDeposit": "UGX 60,000",
        "image": "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&w=500&q=80",
      },
      {
        "title": "Mbarara Weekend Safari",
        "location": "Lake Mburo Gate",
        "date": "Sat Departure",
        "escrowDeposit": "UGX 180,000",
        "image": "https://images.unsplash.com/photo-1516426122078-c23e76319801?auto=format&fit=crop&w=500&q=80",
      },
      {
        "title": "Nyege Nyege Festival",
        "location": "Jinja Nile Rapids",
        "date": "Next Thu - Sun",
        "escrowDeposit": "UGX 120,000",
        "image": "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=500&q=80",
      },
      {
        "title": "Corporate Gala Dinner",
        "location": "Serena Hotel Kampala",
        "date": "Tonight, 7:00 PM",
        "escrowDeposit": "UGX 75,000",
        "image": "https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&w=500&q=80",
      },
    ];

    final vehicleClasses = [
      {"name": "Drone Van", "capacity": "10-14 Seats", "rate": "UGX 180k/day", "icon": Icons.airport_shuttle},
      {"name": "Coaster Bus", "capacity": "28-30 Seats", "rate": "UGX 350k/day", "icon": Icons.directions_bus},
      {"name": "Safari Cruiser", "capacity": "5-7 Seats", "rate": "UGX 400k/day", "icon": Icons.terrain},
    ];

    final escrowSteps = [
      {"title": "Lock Guarantee Deposit", "desc": "Secure your specific fleet assignment by anchoring a partial holding split layout via Mobile Money."},
      {"title": "Funds Guarded In Escrow", "desc": "SmartStage nodes keep your money frozen securely. Fleet operators cannot access it yet."},
      {"title": "Automated Trip Release", "desc": "Payout transfers instantly once round-trip verification milestones clear successfully on return."}
    ];

    final activeConvoys = [
      {"event": "Cranes Match", "route": "Ntinda to Namboole", "slots": "8 seats left", "price": "UGX 6,000"},
      {"event": "Blankets & Wine", "route": "Makerere to Lugogo", "slots": "4 seats left", "price": "UGX 8,500"},
    ];

    return Scaffold(
      backgroundColor: surfaceColor, //This dark mode
      //backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Private Fleet Hires", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: surfaceColor,
        //backgroundColor: Colors.white,
        foregroundColor: headingTextColor, //This is also dark mode
        //foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HERO VALUE STATEMENT
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Dedicated Fleet Allocation",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryColor, letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Book dedicated regional fleets with conditional escrow security deposits",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.3),
                  ),
                ],
              ),
            ),

            // 1. FEATURED ROW (Keep existing functionality)
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: featuredEvents.length,
                itemBuilder: (context, index) {
                  final event = featuredEvents[index];
                  return Container(
                    width: 280,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              event["image"]!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(color: primaryColor.withOpacity(0.1)),
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.85)],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  decoration: BoxDecoration(color: accentGreen, borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.lock_outline, color: Colors.white, size: 12),
                                      const SizedBox(width: 4),
                                      Text("Deposit: ${event['escrowDeposit']}", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(event["title"]!, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined, color: Colors.white.withOpacity(0.7), size: 14),
                                    const SizedBox(width: 4),
                                    Expanded(child: Text("${event['location']} • ${event['date']}", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12), overflow: TextOverflow.ellipsis)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 36),

            // 2. FLEET CLASS DIRECTORY
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: const Text("Available Fleet Classes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: vehicleClasses.length,
                itemBuilder: (context, index) {
                  final item = vehicleClasses[index];
                  final isSelected = _selectedVehicleClass == item["name"];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedVehicleClass = item["name"] as String),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 150,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor.withOpacity(0.05) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSelected ? primaryColor : Colors.grey.shade200, width: 1.5),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Icon(item["icon"] as IconData, color: isSelected ? primaryColor : Colors.black54, size: 20),
                              const SizedBox(width: 8),
                              Text(item["name"] as String, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isSelected ? primaryColor : Colors.black87)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(item["capacity"] as String, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                          Text(item["rate"] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: accentGreen)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 36),

            // 3. QUICK-FORM ROUTE PLANNER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Custom Charter Pipeline", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _pickupController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.circle, color: accentGreen, size: 14),
                        hintText: "Pick-up Station (e.g. Ntinda Hub)",
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _dropoffController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.location_on, color: primaryColor, size: 16),
                        hintText: "Regional Destination (e.g. Jinja)",
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                        child: Text("Query Available $_selectedVehicleClass Fleets", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 36),

            // 4. ESCROW TRANSPARENCY MATRIX
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: const Text("Escrow Security Infrastructure", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: List.generate(escrowSteps.length, (index) {
                  final step = escrowSteps[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: primaryColor.withOpacity(0.1),
                          child: Text("${index + 1}", style: const TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(step["title"]!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                              const SizedBox(height: 4),
                              Text(step["desc"]!, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4)),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 16),

            // 5. CO-SHARING CONVOY POOL
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Active Regional Convoys", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                  Text("Split Costs", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: activeConvoys.length,
              itemBuilder: (context, index) {
                final convoy = activeConvoys[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(color: accentGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.all(10),
                        child: const Icon(Icons.groups_outlined, color: accentGreen),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(convoy["event"]!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                            const SizedBox(height: 2),
                            Text(convoy["route"]!, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(convoy["price"]!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor)),
                          Text(convoy["slots"]!, style: const TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.w500)),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            //NEWWWWWWWWWWWWWWWWWWWWWWW
        Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
    child: SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton.icon(
    onPressed: () {
    showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
    initialChildSize: 0.9,
    maxChildSize: 0.95,
    minChildSize: 0.5,
    builder: (_, controller) => ClipRRect(
    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
    child: Container(
    color: isDarkMode ? const Color(0xFF121212) : Colors.white,
    child: const ParcelTrackingScreen(),
    ),
    ),
    ),
    );
    },
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor.withOpacity(0.1),
        foregroundColor: primaryColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      icon: const Icon(Icons.track_changes, size: 18),
      label: const Text("Track Active Cargo Delivery", style: TextStyle(fontWeight: FontWeight.bold)),
    ),
    ),
        ),
          ],
        ),
      ),
    );
  }
}