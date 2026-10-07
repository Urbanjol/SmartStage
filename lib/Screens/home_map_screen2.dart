import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final FocusNode _destinationFocus = FocusNode();

  GoogleMapController? _mapController;
  List<Journey> _journeys = [];
  Position? _passengerPosition;
  bool _isSearching = false;
  bool _isScanning = false;
  Set<Marker> _markers = {};
  bool _showHeatmap = true;

  List<Map<String, dynamic>> _suggestions = [];
  List<Map<String, dynamic>> _recentSearches = [];
  bool _destinationFocused = false;
  Timer? _debounce;

  List<LatLng> _routePolyline = [];
  LatLng? _destinationLatLng;
  Map<String, dynamic>? _selectedPlace;

  final LatLng _kampalaCenter = const LatLng(0.3136, 32.5811);

  bool _isLoadingDrivers = false;
  String? _errorMessage;
  List<LatLng> _nearbyDriverPositions = [];

  double get originLatitude =>
      _passengerPosition?.latitude ?? _kampalaCenter.latitude;

  double get originLongitude =>
      _passengerPosition?.longitude ?? _kampalaCenter.longitude;

  @override
  void initState() {
    super.initState();
    _pickupController.text = "Current Location";
    _loadPassengerLocation();

    _destinationFocus.addListener(() {
      setState(() {
        _destinationFocused = _destinationFocus.hasFocus;
      });

      if (_destinationFocus.hasFocus &&
          _destinationController.text.isEmpty) {
        _loadRecentSearches();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _pickupController.dispose();
    _destinationController.dispose();
    _destinationFocus.dispose();
    super.dispose();
  }

  Future<void> _loadPassengerLocation() async {
    final position = await PassengerLocationService.getCurrentLocation();

    if (position != null && mounted) {
      setState(() {
        _passengerPosition = position;
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude),
        ),
      );
    }
  }

  Future<void> _loadRecentSearches() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('search_history')
          .orderBy('search_time', descending: true)
          .limit(10)
          .get();

      final seen = <String>{};
      final recent = <Map<String, dynamic>>[];

      for (final doc in snapshot.docs) {
        final dest = doc.data()['destination'] as String? ?? '';
        if (dest.isNotEmpty && !seen.contains(dest)) {
          seen.add(dest);
          recent.add({'name': dest});
        }
        if (recent.length >= 5) break;
      }

      setState(() {
        _recentSearches = recent;
      });
    } catch (e) {
      // Silently fail
    }
  }

  void _onDestinationChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.length < 3) {
      setState(() => _suggestions = []);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () {
      _fetchSuggestions(query);
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    try {
      final callable =
      FirebaseFunctions.instance.httpsCallable('autocompletePlaces');
      final result = await callable.call({'query': query});

      final data = result.data as Map<String, dynamic>;
      final suggestions = data['suggestions'] as List<dynamic>? ?? [];

      if (suggestions.isEmpty) {
        final fallbackCallable =
        FirebaseFunctions.instance.httpsCallable('searchPlaces');
        final fallbackResult = await fallbackCallable.call({'query': query});

        final fallbackData = fallbackResult.data as Map<String, dynamic>;
        final places = fallbackData['places'] as List<dynamic>? ?? [];

        setState(() {
          _suggestions = places.take(5).map((p) {
            final map = p as Map<String, dynamic>;
            return {
              'name': map['name'] ?? '',
              'address': map['address'] ?? '',
              'lat': map['lat'],
              'lng': map['lng'],
            };
          }).toList();
        });
        return;
      }

      setState(() {
        _suggestions = suggestions
            .map((s) => Map<String, dynamic>.from(s as Map))
            .toList();
      });
    } catch (e) {
      // Silently fail
    }
  }

  Future<LatLng?> _fetchPlaceCoordinates(String placeId) async {
    try {
      final callable =
      FirebaseFunctions.instance.httpsCallable('getPlaceDetails');
      final result = await callable.call({'placeId': placeId});

      final data = result.data as Map<String, dynamic>;
      final lat = data['lat'];
      final lng = data['lng'];

      if (lat == null || lng == null) return null;

      return LatLng(lat.toDouble(), lng.toDouble());
    } catch (e) {
      return null;
    }
  }

  double _calculateDistance(LatLng destination) {
    final origin = _passengerPosition;
    if (origin == null) return 0;

    const R = 6371;
    final dLat = _toRadians(destination.latitude - origin.latitude);
    final dLng = _toRadians(destination.longitude - origin.longitude);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(origin.latitude)) *
            cos(_toRadians(destination.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  int _calculateFare(double distanceKm) {
    return (3000 + (distanceKm * 500)).round();
  }

  Widget _buildInfoPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF2563EB)),
          const SizedBox(width: 6),
          Text(text,
              style:
              AppText.caption.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _drawPolyline(LatLng destination) {
    final origin = _passengerPosition;
    if (origin == null) return;

    final originLatLng = LatLng(origin.latitude, origin.longitude);

    setState(() {
      _destinationLatLng = destination;
      _routePolyline = [originLatLng, destination];
    });

    if (_mapController != null) {
      final southWest = LatLng(
        origin.latitude < destination.latitude
            ? origin.latitude
            : destination.latitude,
        origin.longitude < destination.longitude
            ? origin.longitude
            : destination.longitude,
      );

      final northEast = LatLng(
        origin.latitude > destination.latitude
            ? origin.latitude
            : destination.latitude,
        origin.longitude > destination.longitude
            ? origin.longitude
            : destination.longitude,
      );

      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(southwest: southWest, northeast: northEast),
          80,
        ),
      );
    }
  }

  Future<void> _searchJourneys() async {
    final destination = _destinationController.text.trim();
    if (destination.isEmpty) {
      setState(() => _errorMessage = "Please enter a destination");
      return;
    }

    _destinationFocus.unfocus();

    setState(() {
      _isSearching = true;
      _isScanning = true;
      _errorMessage = null;
      _journeys = [];
      _suggestions = [];
      _recentSearches = [];
      _selectedPlace = null;
    });

    try {
      final callable =
      FirebaseFunctions.instance.httpsCallable('findJourney');
      final result = await callable.call({
        'origin': {
          'lat': originLatitude,
          'lng': originLongitude,
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
        'originLat': originLatitude,
        'originLng': originLongitude,
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

  Set<Circle> _buildVehiclePulseCircles(List<TaxiVehicle> taxis) {
    final circles = <Circle>{};

    for (final taxi in taxis) {
      circles.add(
        Circle(
          circleId: CircleId('pulse_${taxi.id}'),
          center: LatLng(taxi.lat, taxi.lng),
          radius: 30,
          fillColor: const Color(0xFF2563EB).withOpacity(0.15),
          strokeColor: Colors.transparent,
          strokeWidth: 0,
        ),
      );
    }

    return circles;
  }

  @override
  Widget build(BuildContext context) {
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
              if (_passengerPosition != null)
                Marker(
                  markerId: const MarkerId('current_location'),
                  position: LatLng(
                    _passengerPosition!.latitude,
                    _passengerPosition!.longitude,
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueAzure,
                  ),
                  zIndex: 1000,
                ),
              if (_destinationLatLng != null)
                Marker(
                  markerId: const MarkerId('destination'),
                  position: _destinationLatLng!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  ),
                ),
            },
            polylines: _routePolyline.isNotEmpty
                ? {
              Polyline(
                polylineId: const PolylineId('route'),
                points: _routePolyline,
                color: const Color(0xFF2563EB),
                width: 6,
                geodesic: true,
              ),
            }
                : {},
            circles: {
              ...(_showHeatmap ? _buildHeatCircles(heatPoints) : {}),
              ..._buildVehiclePulseCircles(taxiAsync.value ?? []),
            },
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

          // Search bar and suggestions
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
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
                                  color: Colors.white,
                                  border: Border.all(
                                      color: const Color(0xFF2563EB),
                                      width: 2.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2563EB)
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 2,
                                height: 38,
                                margin:
                                const EdgeInsets.symmetric(vertical: 4),
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
                                      color: const Color(0xFFFFB800),
                                      width: 2.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFFB800)
                                          .withOpacity(0.3),
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
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                  ),
                                ),
                                Divider(
                                  height: 1,
                                  color: SmartStageColors.greyLight,
                                  thickness: 1,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _destinationController,
                                        focusNode: _destinationFocus,
                                        style: AppText.body,
                                        decoration: InputDecoration(
                                          hintText: "Where to?",
                                          hintStyle: AppText.caption,
                                          border: InputBorder.none,
                                          contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10),
                                        ),
                                        onChanged: _onDestinationChanged,
                                        onSubmitted: (_) => _searchJourneys(),
                                      ),
                                    ),
                                    if (_destinationController.text.isNotEmpty)
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _destinationController.clear();
                                            _suggestions = [];
                                            _selectedPlace = null;
                                            _routePolyline = [];
                                            _destinationLatLng = null;
                                          });
                                        },
                                        child: const Icon(
                                          Icons.close,
                                          size: 18,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Recent searches
                  if (_destinationFocused &&
                      _destinationController.text.isEmpty &&
                      _recentSearches.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
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
                      child: Column(
                        children: _recentSearches.map((search) {
                          return GestureDetector(
                            onTap: () {
                              _destinationController.text = search['name'];
                              _destinationFocus.unfocus();
                              _searchJourneys();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  const Icon(Icons.history,
                                      color: Color(0xFF94A3B8), size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      search['name'],
                                      style: AppText.body,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  // Suggestions
                  if (_suggestions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
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
                      child: Column(
                        children: _suggestions.map((place) {
                          return GestureDetector(
                            onTap: () async {
                              final placeName = place['name'] ?? '';
                              _destinationController.text = placeName;
                              _destinationFocus.unfocus();
                              setState(() {
                                _suggestions = [];
                                _selectedPlace = place;
                              });

                              final lat = place['lat'];
                              final lng = place['lng'];

                              if (lat != null && lng != null) {
                                _drawPolyline(LatLng(
                                  lat.toDouble(),
                                  lng.toDouble(),
                                ));
                              } else if (place['placeId'] != null) {
                                final latLng = await _fetchPlaceCoordinates(
                                    place['placeId']);
                                if (latLng != null) {
                                  _drawPolyline(latLng);
                                }
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Color(0xFF2563EB),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          place['name'] ?? '',
                                          style: AppText.body.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if ((place['address'] ?? '')
                                            .isNotEmpty)
                                          Text(
                                            place['address'],
                                            style: AppText.caption,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  // Destination preview card
                  if (_selectedPlace != null && _destinationLatLng != null)
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Color(0xFF2563EB), size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _selectedPlace!['name'] ?? '',
                                  style: AppText.body.copyWith(
                                      fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedPlace = null;
                                    _routePolyline = [];
                                    _destinationLatLng = null;
                                    _destinationController.clear();
                                  });
                                },
                                child: const Icon(Icons.close,
                                    size: 20, color: Color(0xFF94A3B8)),
                              ),
                            ],
                          ),
                          if ((_selectedPlace!['address'] ?? '')
                              .isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              _selectedPlace!['address'],
                              style: AppText.caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildInfoPill(
                                Icons.straighten,
                                '${_calculateDistance(_destinationLatLng!).toStringAsFixed(1)} km',
                              ),
                              const SizedBox(width: 8),
                              _buildInfoPill(
                                Icons.payments_outlined,
                                'UGX ${_calculateFare(_calculateDistance(_destinationLatLng!))}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _searchJourneys,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding:
                                const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'FIND VEHICLES',
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
                ],
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
                              Text("Vehicles Nearby", style: AppText.title),
                              Text(
                                "${taxiAsync.value?.length ?? 0} active",
                                style: const TextStyle(
                                  color: Color(0xFF2563EB),
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
                            padding: const EdgeInsets.symmetric(horizontal: 24),
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