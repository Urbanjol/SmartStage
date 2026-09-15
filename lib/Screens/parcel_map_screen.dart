import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/parcel_model.dart';

class ParcelMapScreen extends StatefulWidget {
  final ParcelModel parcel;

  const ParcelMapScreen({Key? key, required this.parcel}) : super(key: key);

  @override
  State<ParcelMapScreen> createState() => _ParcelMapScreenState();
}

class _ParcelMapScreenState extends State<ParcelMapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.parcel.trackingCode),
        backgroundColor: const Color(0xFF1E293B),
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(0.3136, 32.5811),
          zoom: 14.5,
        ),
        markers: {
          const Marker(
            markerId: MarkerId('parcel'),
            position: LatLng(0.3136, 32.5811),
            infoWindow: InfoWindow(title: 'Parcel Location'),
          ),
        },
      ),
    );
  }
}