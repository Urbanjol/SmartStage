import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

// Import all the reusable components
import '../Widgets/primary_action_button.dart';
import '../Widgets/price_tag.dart';
import '../Widgets/error_message.dart';
import '../Widgets/morph_transition_button.dart';
import '../Widgets/taxi_metal_poster_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/Journey_model.dart';
import '../Widgets/journey_results_sheet.dart';


class HomeMapScreen extends ConsumerStatefulWidget {
  const HomeMapScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends ConsumerState<HomeMapScreen> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final MapController _mapController = MapController();
  List<Journey> _journeys = [];
  bool _isSearching = false;

  // Mock initial coordinates for Kampala, Uganda central hub
  final LatLng _kampalaCenter = const LatLng(0.3136, 32.5811);

  bool _isLoadingDrivers = false;
  String? _errorMessage;
  List<LatLng> _nearbyDriverPositions = [];

  @override
  void initState() {
    super.initState();
    _pickupController.text = "Current Location (Kampala Stage)";
  }

  //new new new new new new new new new ne w
  Future<void> _searchJourneys() async {
    final destination = _destinationController.text.trim();
    if (destination.isEmpty) {
      setState(() => _errorMessage = "Please enter a destination");
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _journeys = [];
    });

    try {
      final callable =
      FirebaseFunctions.instance.httpsCallable('findJourney');
      final result = await callable.call({
        'origin': {
          'lat': _kampalaCenter.latitude,
          'lng': _kampalaCenter.longitude,
        },
        'destination': destination,
        'preference': 'fastest',
      });

      final data = result.data as Map<String, dynamic>;
      final journeysList = data['journeys'] as List<dynamic>? ?? [];

      setState(() {
        _journeys = journeysList
            .map((j) => Journey.fromJson(j as Map<String, dynamic>))
            .toList();
        _isSearching = false;

        if (_journeys.isEmpty) {
          _errorMessage = "No routes found to $destination";
        }
      });

      if (_journeys.isNotEmpty) {
        _showJourneyResults();
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
        _errorMessage = "Search failed: $e";
      });
    }
  }

  void _showJourneyResults() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        builder: (context, scrollController) => JourneyResultsSheet(
          journeys: _journeys,
          destination: _destinationController.text.trim(),
        ),
      ),
    );
  }

  //triggers real cloud function routing instead of mock data
  Future<void>_searchNearbyTaxis() async {
    setState(() {
      _isLoadingDrivers = true;
      _errorMessage = null;
    });
    try{
      final destination = _destinationController.text.trim();
      if (destination.isEmpty){
        setState(() {
          _errorMessage = "Please enter a destination";
          _isLoadingDrivers = false;
        });
        return;
      }
      //call the cloud functions
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('findJourney');
      final result = await callable.call({
        'origin':{
          'lat': _kampalaCenter.latitude,
          'lng': _kampalaCenter.longitude,
        },
        'destination': destination,
        'preference': 'fastest'
      });
      final data = result.data as Map<String,dynamic>;
      final journeys = data['journeys'] as List<dynamic>;
      if(journeys.isEmpty){
        setState((){
         _errorMessage = "No taxi found for this route";
         _isLoadingDrivers = false;
        });
        return;
      }
      //Extract taxi positions from journey legs
      //for now we place them near stages on the route
      final List<LatLng> driverPositions = [];
      for(final journey in journeys){
        final legs = journey['legs'] as List<dynamic>;
        for(final leg in legs){
          // We need stage coordinates. For now, offset from center.
          // In production, store stage coordinates and use them.
          final stageName = leg['stage'] as String;
          // Simple offset based on stage name hash
          final offset = stageName.hashCode % 10;
          driverPositions.add(LatLng(
              _kampalaCenter.latitude + (offset - 5) * 0.005,
              _kampalaCenter.longitude + (offset - 5) * 0.005,
          ));
        }
      }
      setState(() {
        _nearbyDriverPositions = driverPositions;
        _isLoadingDrivers = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingDrivers = false;
        _errorMessage = "Could not find journeys: $e";
      });
    }
  }

  /// Triggers spatial indexing simulation matching
  Future<void> _searchNearbyTaxisC() async {
    setState(() {
      _isLoadingDrivers = true;
      _errorMessage = null;
    });

    try {
      double currentLat = _kampalaCenter.latitude;
      double currentLng = _kampalaCenter.longitude;

      // Mocking spatial drivers found inside the local H3 ring
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _nearbyDriverPositions = [
          LatLng(currentLat + 0.003, currentLng + 0.002), // Driver A
          LatLng(currentLat - 0.002, currentLng + 0.004), // Driver B
          LatLng(currentLat + 0.001, currentLng - 0.003), // Driver C
        ];
        _isLoadingDrivers = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingDrivers = false;
        _errorMessage = "Could not parse spatial indices: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. THE LIVE MAP LAYER
          FlutterMap(
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

              // MARKER LAYER: Renders taxis and custom floating PriceTagCards cleanly
              MarkerLayer(
                markers: _nearbyDriverPositions.map((driverLatLng) {
                  return Marker(
                    point: driverLatLng,
                    width: 320,   // Adjusted to prevent text horizontal clip
                    height: 320,  // FIXED: Expanded to prevent the vertical RenderFlex overflow error
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //lets implement our taxi metal card
                        const TaxiMetalPosterCard(
                          stageDeparture: "OLD TAXI PARK (MBARARA STAGE)",
                          destination: "MBARARA",
                          fare: "25000UGX",
                          loadedSeats: 12,
                          totalSeats: 14,
                        ),
                       // const PriceTag(
                         // routeDestination: "Entebbe Rd",
                          //priceUGX: 3500,
                        //),
                        const SizedBox(height: 4),
                        const Icon(
                          Icons.directions_car,
                          color: Color(0xFF0056b3), // Taxi Blue
                          size: 28,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // 2. THE TOP INPUT CONTROLLER OVERLAY (PREMIUM FLOATING COMMAND CENTER)
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.96), // Translucent premium white
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
                        // A. THE PREMIUM DOTTED ROUTE LINE GRAPHIC
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

                        // B. THE INTEGRATED FORM FIELDS PIPELINE
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
                        // Soft pill handle indicator
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
                        //PrimaryActionButton(
                          //replace the PrimaryActionButton with our Morph_transition
                          MorphingActionButton(
                            onScanningStarted: () {
                              _searchJourneys();
                              //_searchNearbyTaxis();
                              //,
                              //label: _nearbyDriverPositions.isEmpty ? "Scan SmartStage Rings" : "Confirm Stage Order",
                              //isLoading: _isLoadingDrivers,
                             // onTap: _searchNearbyTaxis
                              //,
                            }
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
    super.dispose();
  }
}

// 4. MATHEMATICAL DOTTED CONNECTOR PAINTER ENGINE
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