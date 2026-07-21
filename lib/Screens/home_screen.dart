import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

// Import all the reusable components
import '../Widgets/primary_action_button.dart';
import '../Widgets/price_tag.dart';
import '../Widgets/error_message.dart';
import '../Widgets/taxi_metal_poster_card.dart';

class HomeMapScreen extends ConsumerStatefulWidget {
  const HomeMapScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeMapScreen> createState() => _HomeMapScreenState();
}

// Added TickerProviderStateMixin to feed the hardware animation clock
class _HomeMapScreenState extends ConsumerState<HomeMapScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final MapController _mapController = MapController();

  final LatLng _kampalaCenter = const LatLng(0.3136, 32.5811);

  bool _isLoadingDrivers = false;
  String? _errorMessage;
  List<LatLng> _nearbyDriverPositions = [];

  // Animation controllers for the spatial radar ripple
  late AnimationController _rippleAnimationController;

  @override
  void initState() {
    super.initState();
    _pickupController.text = "Current Location (Kampala Stage)";

    // Set up a 2-second looping lifecycle for the wave expands
    _rippleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
  }

  /// Triggers spatial indexing simulation matching + fires ripple wave loops
  Future<void> _searchNearbyTaxis() async {
    setState(() {
      _isLoadingDrivers = true;
      _errorMessage = null;
      _nearbyDriverPositions = []; // Clear current cars to emphasize search state
    });

    // Fire the continuous radar wave loop
    _rippleAnimationController.repeat();

    try {
      double currentLat = _kampalaCenter.latitude;
      double currentLng = _kampalaCenter.longitude;

      // Mocking network index delay
      await Future.delayed(const Duration(seconds: 4));

      if (!mounted) return;

      setState(() {
        _nearbyDriverPositions = [
          LatLng(currentLat + 0.003, currentLng + 0.002),
          LatLng(currentLat - 0.002, currentLng + 0.004),
          LatLng(currentLat + 0.001, currentLng - 0.003),
        ];
        _isLoadingDrivers = false;
      });

      // Turn off the radar animation smoothly once drivers populate
      _rippleAnimationController.stop();
      _rippleAnimationController.reset();

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingDrivers = false;
        _rippleAnimationController.stop();
        _rippleAnimationController.reset();
        _errorMessage = "Could not parse spatial indices: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. THE LIVE MAP LAYER WITH INTEGRATED RIPPLE BUILDER
          AnimatedBuilder(
            animation: _rippleAnimationController,
            builder: (context, child) {
              // Calculate values mathematically based on the current tick value [0.0 -> 1.0]
              double progress = _rippleAnimationController.value;

              // Wave 1: Expands from 0 to 450 meters
              double radius1 = progress * 450;
              // Fade opacity to 0 dynamically as the circle expands outward
              double opacity1 = (1.0 - progress).clamp(0.0, 0.15);

              // Wave 2: Staggered secondary echo ring following slightly behind
              double progress2 = (progress + 0.5) > 1.0 ? (progress - 0.5) : (progress + 0.5);
              double radius2 = progress2 * 450;
              double opacity2 = (1.0 - progress2).clamp(0.0, 0.10);

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _kampalaCenter,
                  initialZoom: 14.5,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.smartstage.app',
                  ),

                  // THE AUTOMATED RADAR CIRCLE LAYER MATRIX
                  if (_isLoadingDrivers)
                    CircleLayer(
                      circles: [
                        // Primary Spatial Radar Ring
                        CircleMarker(
                          point: _kampalaCenter,
                          radius: radius1,
                          useRadiusInMeter: true,
                          color: const Color(0xFF0056b3).withOpacity(opacity1),
                          borderColor: const Color(0xFF0056b3).withOpacity(opacity1 * 2),
                          borderStrokeWidth: 2,
                        ),
                        // Secondary Delayed Staggered Follow Ring
                        CircleMarker(
                          point: _kampalaCenter,
                          radius: radius2,
                          useRadiusInMeter: true,
                          color: const Color(0xFF0056b3).withOpacity(opacity2),
                          borderColor: const Color(0xFF0056b3).withOpacity(opacity2 * 2),
                          borderStrokeWidth: 1.5,
                        ),
                      ],
                    ),

                  // MARKER LAYER: Taxis and price tags
                  MarkerLayer(
                    markers: [
                      // An explicit pulsing pinpoint anchor marker for the Passenger Center Hub
                      Marker(
                        point: _kampalaCenter,
                        width: 120,
                        height: 120,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF0056b3),
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                        ),
                      ),

                      // Available matching driver icons
                      ..._nearbyDriverPositions.map((driverLatLng) {
                        return Marker(
                          point: driverLatLng,
                          width: 120,
                          height: 120,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const TaxiMetalPosterCard(
                                stageDeparture: "OLD TAXI PARK (MBARARA STAGE)",
                                destination: "MBARARA",
                                fare: "25000UGX",
                                loadedSeats: 12,
                                totalSeats: 14,
                              ),
                              //const PriceTag(
                                //routeDestination: "Entebbe Rd",
                                //priceUGX: 3500,
                              //),
                              const SizedBox(height: 4),
                              const Icon(
                                Icons.directions_car,
                                color: Color(0xFF0056b3),
                                size: 28,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ],
              );
            },
          ),

          // 2. THE TOP INPUT CONTROLLER OVERLAY (PREMIUM FLOATING COMMAND CENTER)
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0056b3).withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(color: const Color(0xFF10B981), width: 2.5),
                              ),
                            ),
                            Container(
                              width: 2,
                              height: 38,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: CustomPaint(
                                painter: DottedLinePainter(color: Colors.grey.shade300),
                              ),
                            ),
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(color: const Color(0xFF0056b3), width: 2.5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: _pickupController,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                                decoration: InputDecoration(
                                  hintText: "Pickup Station",
                                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400, fontWeight: FontWeight.w400),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                              Divider(height: 1, color: Colors.grey.shade100, thickness: 1),
                              TextField(
                                controller: _destinationController,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                                decoration: InputDecoration(
                                  hintText: "Where to? (e.g. Mukono, Masaka)",
                                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400, fontWeight: FontWeight.w400),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 3. BOTTOM CONTROL DRAWER & INTERACTION PANELS
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_errorMessage != null)
                    ErrorMessage(
                      errorMessage: _errorMessage!,
                      onRetry: _searchNearbyTaxis,
                    ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 16,
                            offset: const Offset(0, -4),
                          )
                        ]
                    ),
                    padding: const EdgeInsets.only(bottom: 24, top: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Available Taxis Nearby",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                              ),
                              Text(
                                "${_nearbyDriverPositions.length} Taxis Found",
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        PrimaryActionButton(
                          label: _isLoadingDrivers
                              ? "Searching Spatial Grid..."
                              : (_nearbyDriverPositions.isEmpty ? "Scan SmartStage Rings" : "Confirm Stage Order"),
                          isLoading: _isLoadingDrivers,
                          onTap: _searchNearbyTaxis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    _rippleAnimationController.dispose(); // Kill hardware animation controller to avoid engine memory leaks
    super.dispose();
  }
}

// 4. DOTTED CONNECTOR PAINTER ENGINE
class DottedLinePainter extends CustomPainter {
  final Color color;
  DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 4, dashSpace = 3, startY = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width
      ..style = PaintingStyle.stroke;

    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}