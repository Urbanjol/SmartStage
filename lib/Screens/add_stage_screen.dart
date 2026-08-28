import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Config/theme.dart';

class AddStageScreen extends ConsumerStatefulWidget {
  const AddStageScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddStageScreen> createState() => _AddStageScreenState();
}

class _AddStageScreenState extends ConsumerState<AddStageScreen> {
  final TextEditingController _nameController = TextEditingController();
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  bool _isSaving = false;

  static const LatLng _kampalaCenter = LatLng(0.3136, 32.5811);

  Future<void> _submitStage() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a stage name'),
          backgroundColor: SmartStageColors.red,
        ),
      );
      return;
    }

    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please tap the map to select a location'),
          backgroundColor: SmartStageColors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final callable = FirebaseFunctions.instance.httpsCallable('addStage');
      final result = await callable.call({
        'name': _nameController.text.trim(),
        'location': {
          'lat': _selectedLocation!.latitude,
          'lng': _selectedLocation!.longitude,
        },
        'added_by': FirebaseAuth.instance.currentUser?.uid ?? 'anonymous',
      });

      final data = result.data as Map<String, dynamic>;

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['created'] == true
                  ? 'Stage added! Waiting for confirmations.'
                  : 'Stage already exists. Vote recorded.',
            ),
            backgroundColor: SmartStageColors.electricGreen,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add stage: $e'),
          backgroundColor: SmartStageColors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADD PICKUP POINT'),
        backgroundColor: SmartStageColors.deepNavy,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _kampalaCenter,
              zoom: 14.5,
            ),
            onMapCreated: (controller) {
              setState(() {
                _mapController = controller;
              });
            },
            onTap: (latLng) {
              setState(() {
                _selectedLocation = latLng;
              });
            },
            markers: _selectedLocation != null
                ? {
              Marker(
                markerId: const MarkerId('selected'),
                position: _selectedLocation!,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen,
                ),
              ),
            }
                : {},
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Stage name (e.g. Kireka Stage)',
                        prefixIcon: Icon(Icons.place),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _selectedLocation == null
                          ? 'Tap the map to select the location'
                          : 'Location selected: ${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: SmartStageColors.greyDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: GlowButton(
                text: _isSaving ? 'SUBMITTING...' : 'SUBMIT PICKUP POINT',
                color: SmartStageColors.gold,
                glowColor: SmartStageColors.goldGlow,
                onPressed: _isSaving ? () {} : _submitStage,
              ),
            ),
          ),
        ],
      ),
    );
  }
}