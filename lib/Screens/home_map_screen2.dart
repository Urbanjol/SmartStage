import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../Screens/assistant_screen.dart';
import '../Config/theme.dart';
import '../Config/app_config.dart';
import '../Services/passenger_location.dart';
import '../Widgets/error_message.dart';
import '../Widgets/morph_transition_button.dart';
import '../models/Journey_model.dart';
import '../Widgets/journey_results_sheet.dart';
import '../Screens/add_stage_screen.dart';
import '../Providers/taxi_stream_provider.dart';
import '../Widgets/vehicle_info_sheet.dart';
import '../Providers/search_history_provider.dart';

class HomeMapScreen extends ConsumerStatefulWidget {
  const HomeMapScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends ConsumerState<HomeMapScreen> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  GoogleMapController? _mapController;
  List<Journey> _journeys = [];
  Position? _passengerPosition;
  bool _isSearching = false;
  bool _isScanning = false;
  Set<Marker> _markers = {};
  bool _showHeatmap = true;

  final LatLng _kampalaCenter = const LatLng(0.3136, 32.5811);

  bool _isLoadingDrivers = false;
  String? _errorMessage;
  List<LatLng> _nearbyDriverPositions = [];

  @override
  void initState() {
    super.initState();
    _pickupController.text = "Current Location (Kampala Stage)";
    _loadPassengerLocation();
  }

  Future<void> _loadPassengerLocation() async {
    final position = await PassengerLocationService.getCurrentLocation();

    if (position != null && mounted) {
      setState(() {
        _passengerPosition = position;
      });
    }
  }

  Future<void> _searchJourneys() async {
    final destination = _destinationController.text.trim();
    if (destination.isEmpty) {
      setState(() => _errorMessage = "Please enter a destination");
      return;
    }

    setState(() {
      _isSearching = true;
      _isScanning = true;
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
            .map((j) => Journey.fromJson(Map<String, dynamic>.from(j as Map)))
            .toList();

        _isSearching = false;
        _isScanning = false;

        if (_journeys.isEmpty) {
          _errorMessage = "No direct routes found. Trying connections...";
        }
      });

      if (_journeys.isEmpty) {
        await _tryMultimodalSearch(destination);
      } else {
        _showJourneyResults();
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
        _isScanning = false;
        _errorMessage = "Search failed: $e";
      });
    }
  }

  Future<void> _tryMultimodalSearch(String destination) async {
    try {
      final callable =
      FirebaseFunctions.instance.httpsCallable('findMultimodalJourney');
      final result = await callable.call({
        'origin': 'Old Taxi Park',
        'destination': destination,
      });

      final data = result.data as Map<String, dynamic>;
      final journeysList = data['journeys'] as List<dynamic>? ?? [];

      setState(() {
        _journeys = journeysList
            .map((j) => Journey.fromJson(Map<String, dynamic>.from(j as Map)))
            .toList();
        _isScanning = false;

        if (_journeys.isEmpty) {
          _errorMessage = "No routes found to $destination";
        }
      });

      if (_journeys.isNotEmpty) {
        _showJourneyResults();
      }
    } catch (e) {
      setState(() {
        _isScanning = false;
        _errorMessage = "Could not find connections: $e";
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

  Set<Marker> _buildAllMarkers(List<TaxiVehicle> taxis) {
    final markers = <Marker>{};

    for (final taxi in taxis) {
      markers.add(
        Marker(
          markerId: MarkerId(taxi.id),
          position: LatLng(taxi.lat, taxi.lng),
          onTap: () {
            showVehicleInfoSheet(
              context,
              taxi,
              passengerPosition: _passengerPosition,
            );
          },
          icon: BitmapDescriptor.defaultMarkerWithHue(
            taxi.vehicleType == 'e_bus'
                ? BitmapDescriptor.hueGreen
                : taxi.vehicleType == 'bus'
                ? BitmapDescriptor.hueViolet
                : BitmapDescriptor.hueBlue,
          ),
        ),
      );
    }

    return markers;
  }

  Set<Circle> _buildHeatCircles(List<SearchPoint> points) {
    final circles = <Circle>{};

    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final intensity = (point.count / 10).clamp(0.1, 1.0);

      circles.add(
        Circle(
          circleId: CircleId('heat_$i'),
          center: LatLng(point.lat, point.lng),
          radius: 200 + (point.count * 30).toDouble(),
          fillColor: Color.lerp(
            Colors.yellow.withOpacity(0.3),
            Colors.red.withOpacity(0.4),
            intensity,
          )!,
          strokeColor: Colors.transparent,
          strokeWidth: 0,
        ),
      );
    }

    return circles;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final taxiAsync = ref.watch(taxiStreamProvider);
    final heatAsync = ref.watch(searchHistoryProvider);
    final heatPoints = heatAsync.value ?? [];

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _kampalaCenter,
              zoom: 14.5,
              tilt: 45,
            ),
            markers: {
              ..._buildAllMarkers(taxiAsync.value ?? []),
              ..._markers,
            },
            circles: _showHeatmap ? _buildHeatCircles(heatPoints) : {},
            onMapCreated: (controller) {
              setState(() {
                _mapController = controller;
              });
            },
          ),

          // Right side buttons
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16, right: 16),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddStageScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_location_alt_outlined,
                          color: Color(0xFF2563EB),
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _showHeatmap = !_showHeatmap;
                        });
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _showHeatmap
                              ? const Color(0xFFEF4444)
                              : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.local_fire_department,
                          color: _showHeatmap
                              ? Colors.white
                              : const Color(0xFFEF4444),
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search bar
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                              border: Border.all(
                                  color: SmartStageColors.electricGreen,
                                  width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: SmartStageColors.greenGlow,
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 2,
                            height: 38,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: CustomPaint(
                              painter: DottedLinePainter(
                                  color: SmartStageColors.greyLight),
                            ),
                          ),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                  color: SmartStageColors.gold, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: SmartStageColors.goldGlow,
                                  blurRadius: 8,
                                ),
                              ],
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
                              style: AppText.body,
                              decoration: InputDecoration(
                                hintText: "Pickup Station",
                                hintStyle: AppText.caption,
                                border: InputBorder.none,
                                contentPadding:
                                const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                            Divider(
                              height: 1,
                              color: SmartStageColors.greyLight,
                              thickness: 1,
                            ),
                            TextField(
                              controller: _destinationController,
                              style: AppText.body,
                              decoration: InputDecoration(
                                hintText: "Where to? (e.g. Mukono)",
                                hintStyle: AppText.caption,
                                border: InputBorder.none,
                                contentPadding:
                                const EdgeInsets.symmetric(vertical: 10),
                              ),
                              onSubmitted: (_) => _searchJourneys(),
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

          // Bottom sheet
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
                      onRetry: _searchJourneys,
                    ),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 16,
                          offset: Offset(0, -4),
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
                            color: SmartStageColors.greyLight,
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
                                "Vehicles Nearby",
                                style: AppText.title,
                              ),
                              Text(
                                "${taxiAsync.value?.length ?? 0} active",
                                style: TextStyle(
                                  color: SmartStageColors.electricGreen,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 60,
                          width: double.infinity,
                          child: Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 24),
                            child: MorphingActionButton(
                              isScanning: _isScanning,
                              onScanningStarted: () {
                                _searchJourneys();
                              },
                            ),
                          ),
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
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AssistantScreen(),
              ),
            );
          },
          backgroundColor: const Color(0xFF2563EB),
          child: const Icon(
            Icons.chat_bubble_outline,
            color: Colors.white,
          ),
        ),
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