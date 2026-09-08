import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../Screens/assistant_screen.dart';
import '../Config/theme.dart';
import '../Widgets/primary_action_button.dart';
import '../Widgets/price_tag.dart';
import '../Widgets/error_message.dart';
import '../Widgets/morph_transition_button.dart';
import '../Widgets/taxi_metal_poster_card.dart';
import '../models/Journey_model.dart';
import '../Widgets/journey_results_sheet.dart';
import '../Screens/add_stage_screen.dart';
import '../Providers/taxi_stream_provider.dart';
import '../Widgets/vehicle_info_sheet.dart';

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
  bool _isSearching = false;
  bool _isScanning = false;
  Set<Marker> _markers = {};

  final LatLng _kampalaCenter = const LatLng(0.3136, 32.5811);

  bool _isLoadingDrivers = false;
  String? _errorMessage;
  List<LatLng> _nearbyDriverPositions = [];

  @override
  void initState() {
    super.initState();
    _pickupController.text = "Current Location (Kampala Stage)";
  }

//new searchJourney function
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
          _errorMessage = "No routes found to $destination";
        }
      });

      if (_journeys.isNotEmpty) {
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
  //end of the function

  Future<void> _searchJourneys2() async {
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
      //new
      final journeysList = data['journeys'] as List<dynamic>? ?? [];

      setState(() {
        _journeys = journeysList
            .map((j) => Journey.fromJson(Map<String, dynamic>.from(j as Map)))
            .toList();
      //ended
      //final journeysList = data['journeys'] as List<dynamic>? ?? [];

      //setState(() {
       // _journeys = journeysList
         //   .map((j) => Journey.fromJson(j as Map<String, dynamic>))
           // .toList();
        //ends
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

  //new updated _search function
  Future<void> _searchNearbyTaxis() async {
    setState(() {
      _isLoadingDrivers = true;
      _isScanning = true;
      _errorMessage = null;
    });
    try {
      final destination = _destinationController.text.trim();
      if (destination.isEmpty) {
        setState(() {
          _errorMessage = "Please enter a destination";
          _isLoadingDrivers = false;
          _isScanning = false;
        });
        return;
      }

      final HttpsCallable callable =
      FirebaseFunctions.instance.httpsCallable('findJourney');
      final result = await callable.call({
        'origin': {
          'lat': _kampalaCenter.latitude,
          'lng': _kampalaCenter.longitude,
        },
        'destination': destination,
        'preference': 'fastest'
      });
      final data = result.data as Map<String, dynamic>;

      final journeysRaw = data['journeys'] as List<dynamic>? ?? [];

      if (journeysRaw.isEmpty) {
        setState(() {
          _errorMessage = "No taxi found for this route";
          _isLoadingDrivers = false;
          _isScanning = false;
        });
        return;
      }

      final List<LatLng> driverPositions = [];
      for (final journeyRaw in journeysRaw) {
        final journey = Map<String, dynamic>.from(journeyRaw as Map);
        final legs = journey['legs'] as List<dynamic>? ?? [];

        for (final legRaw in legs) {
          final leg = Map<String, dynamic>.from(legRaw as Map);
          final stageName = leg['stage'] as String? ?? 'Unknown';
          final offset = stageName.hashCode % 10;
          driverPositions.add(LatLng(
            _kampalaCenter.latitude + (offset - 5) * 0.005,
            _kampalaCenter.longitude + (offset - 5) * 0.005,
          ));
        }
      }

      setState(() {
        _nearbyDriverPositions = driverPositions;
        _markers = driverPositions.map((pos) {
          return Marker(
            markerId: MarkerId(pos.toString()),
            position: pos,
            infoWindow: const InfoWindow(title: "Taxi"),
          );
        }).toSet();
        _isLoadingDrivers = false;
        _isScanning = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingDrivers = false;
        _isScanning = false;
        _errorMessage = "Could not find journeys: $e";
      });
    }
  }
//method to build markers from taxis
  Set<Marker> _buildTaxiMarkers(List<TaxiVehicle> taxis, bool isDark) {
    final markers = <Marker>{};

    for (final taxi in taxis) {
      final color = taxi.vehicleType == 'e_bus'
          ? const Color(0xFF10B981)
          : taxi.vehicleType == 'bus'
          ? const Color(0xFF7B2FF7)
          : const Color(0xFF2563EB);

      markers.add(
        Marker(
          markerId: MarkerId(taxi.id),
          position: LatLng(taxi.lat, taxi.lng),
          onTap: () {
            showVehicleInfoSheet(context,taxi);
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
  //end of method
  Future<void> _searchNearbyTaxis2() async {
    setState(() {
      _isLoadingDrivers = true;
      _errorMessage = null;
    });
    try {
      final destination = _destinationController.text.trim();
      if (destination.isEmpty) {
        setState(() {
          _errorMessage = "Please enter a destination";
          _isLoadingDrivers = false;
        });
        return;
      }

      final HttpsCallable callable =
      FirebaseFunctions.instance.httpsCallable('findJourney');
      final result = await callable.call({
        'origin': {
          'lat': _kampalaCenter.latitude,
          'lng': _kampalaCenter.longitude,
        },
        'destination': destination,
        'preference': 'fastest'
      });
      final data = result.data as Map<String, dynamic>;

      final journeys = data['journeys'] as List<dynamic>;

      if (journeys.isEmpty) {
        setState(() {
          _errorMessage = "No taxi found for this route";
          _isLoadingDrivers = false;
        });
        return;
      }

      final List<LatLng> driverPositions = [];
      for (final journey in journeys) {
        final legs = journey['legs'] as List<dynamic>;
        for (final leg in legs) {
          final stageName = leg['stage'] as String;
          final offset = stageName.hashCode % 10;
          driverPositions.add(LatLng(
            _kampalaCenter.latitude + (offset - 5) * 0.005,
            _kampalaCenter.longitude + (offset - 5) * 0.005,
          ));
        }
      }

      setState(() {
        _nearbyDriverPositions = driverPositions;
        _markers = driverPositions.map((pos) {
          return Marker(
            markerId: MarkerId(pos.toString()),
            position: pos,
            infoWindow: const InfoWindow(title: "Taxi"),
          );
        }).toSet();
        _isLoadingDrivers = false;
        _isScanning = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingDrivers = false;
        _isScanning = false;
        _errorMessage = "Could not find journeys: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final taxiAsync = ref.watch(taxiStreamProvider);

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _kampalaCenter,
              zoom: 14.5,
            ),
            markers: {
              ...?_buildTaxiMarkers(
                taxiAsync.value ?? [],
                isDark,
              ),
              ..._markers,
            },
            //markers: _markers,
            onMapCreated: (controller) {
              setState(() {
                _mapController = controller;
              });
            },
          ),
        //Add new stages strt
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
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
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.4),
                          blurRadius: 15,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_location_alt_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
          //end
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark
                      ? SmartStageColors.navyCard.withOpacity(0.95)
                      : Colors.white.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? Colors.white10
                        : Colors.white.withOpacity(0.6),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 16),
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
                                color: isDark
                                    ? SmartStageColors.navyCard
                                    : Colors.white,
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
                                    color: isDark
                                        ? SmartStageColors.greyDark
                                        : SmartStageColors.greyLight),
                              ),
                            ),
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? SmartStageColors.navyCard
                                    : Colors.white,
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
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? SmartStageColors.white
                                      : SmartStageColors.deepNavy,
                                ),
                                decoration: InputDecoration(
                                  hintText: "Pickup Station",
                                  hintStyle: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? SmartStageColors.greyMid
                                        : SmartStageColors.greyDark,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding:
                                  const EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                              Divider(
                                height: 1,
                                color: isDark
                                    ? Colors.white10
                                    : SmartStageColors.greyLight,
                                thickness: 1,
                              ),
                              TextField(
                                controller: _destinationController,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? SmartStageColors.white
                                      : SmartStageColors.deepNavy,
                                ),
                                decoration: InputDecoration(
                                  hintText: "Where to? (e.g. Mukono, Masaka)",
                                  hintStyle: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? SmartStageColors.greyMid
                                        : SmartStageColors.greyDark,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding:
                                  const EdgeInsets.symmetric(vertical: 10),
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
                      color: isDark
                          ? SmartStageColors.navyCard
                          : Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.only(bottom: 24, top: 12),
                    child: SingleChildScrollView(
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
                                  "Available Taxis Nearby",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isDark
                                        ? SmartStageColors.white
                                        : SmartStageColors.deepNavy,
                                  ),
                                ),
                                Text(
                                  "${_nearbyDriverPositions.length} Taxis Found",
                                  style: TextStyle(
                                    color: SmartStageColors.electricGreen,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          //new morph code for button scan smart rings
                          SizedBox(
                            height: 60,
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: MorphingActionButton(
                                isScanning: _isScanning,
                                onScanningStarted: () {
                                  _searchJourneys();
                                },
                              ),
                            ),
                          ),
                          //end of morph code
                          //const SizedBox(height: 16),
                          //SizedBox(
                            //height: 60,
                            //width: double.infinity,
                            //child: Padding(
                              //padding: const EdgeInsets.symmetric(horizontal: 24),
                              //child: MorphingActionButton(
                                //onScanningStarted: () {
                                  //_searchJourneys();
                                //},
                              //),
                            //),
                          //),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      //floating button fo AI assistant
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7B2FF7).withOpacity(0.5),
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
          backgroundColor: const Color(0xFF7B2FF7),
          child: const Icon(
            Icons.chat_bubble_outline,
            color: Color(0xFFFFB800),
          ),
        ),
      ),
      //end of floating AI assistant
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