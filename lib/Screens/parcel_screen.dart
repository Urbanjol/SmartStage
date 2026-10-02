import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Config/app_config.dart';
import '../Providers/parcel_provider.dart';
import '../models/parcel_model.dart';
import '../Widgets/parcel_service_card.dart';
import '../Widgets/current_tracking_card.dart';
import '../Widgets/recent_order_card.dart';
import 'parcel_map_screen.dart';

class ParcelScreen extends ConsumerStatefulWidget {
  const ParcelScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ParcelScreen> createState() => _ParcelScreenState();
}

class _ParcelScreenState extends ConsumerState<ParcelScreen> {
  final TextEditingController _trackingController = TextEditingController();
  final TextEditingController _senderNameController = TextEditingController();
  final TextEditingController _receiverNameController = TextEditingController();
  final TextEditingController _receiverPhoneController = TextEditingController();
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _fareController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(parcelProvider.notifier).loadMyParcels();
    });
  }

  @override
  void dispose() {
    _trackingController.dispose();
    _senderNameController.dispose();
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();
    _pickupController.dispose();
    _destinationController.dispose();
    _fareController.dispose();
    super.dispose();
  }

  void _searchTracking() {
    final code = _trackingController.text.trim();
    if (code.isEmpty) return;

    ref.read(parcelProvider.notifier).trackParcel(code);
  }

  void _showCreateParcelSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreateParcelSheet(
        senderNameController: _senderNameController,
        receiverNameController: _receiverNameController,
        receiverPhoneController: _receiverPhoneController,
        pickupController: _pickupController,
        destinationController: _destinationController,
        fareController: _fareController,
        onCreate: () async {
          if (_senderNameController.text.trim().isEmpty ||
              _receiverNameController.text.trim().isEmpty ||
              _receiverPhoneController.text.trim().isEmpty ||
              _pickupController.text.trim().isEmpty ||
              _destinationController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please fill all required fields', style: AppText.body.copyWith(color: Colors.white)),
                backgroundColor: const Color(0xFFEF4444),
              ),
            );
            return;
          }

          final trackingCode = await ref
              .read(parcelProvider.notifier)
              .createParcel(
            senderName: _senderNameController.text.trim(),
            receiverName: _receiverNameController.text.trim(),
            receiverPhone: _receiverPhoneController.text.trim(),
            pickupStage: _pickupController.text.trim(),
            destinationStage: _destinationController.text.trim(),
            fare: double.tryParse(_fareController.text.trim()) ?? 0,
          );

          if (trackingCode != null && mounted) {
            _showSuccessDialog(trackingCode);
            ref.read(parcelProvider.notifier).loadMyParcels();
          }
        },
      ),
    );
  }

  void _showSuccessDialog(String trackingCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'PARCEL CREATED',
          style: AppText.header.copyWith(fontSize: 16, color: const Color(0xFF2563EB)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Your parcel has been created.', style: AppText.body),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                trackingCode,
                style: AppText.number.copyWith(fontSize: 14, color: const Color(0xFF2563EB)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Share this code with the receiver',
              style: AppText.caption,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: AppText.body.copyWith(
                color: const Color(0xFF2563EB),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(parcelProvider);
    final activeParcel = state.myParcels.isNotEmpty
        ? state.myParcels.firstWhere(
          (p) => p.status != ParcelStatus.delivered,
      orElse: () => state.myParcels.first,
    )
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'PARCEL SERVICES',
          style: AppText.header.copyWith(fontSize: 16, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search,
                    color: Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _trackingController,
                      style: AppText.body,
                      decoration: InputDecoration(
                        hintText: 'Enter tracking code',
                        hintStyle: AppText.caption,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onSubmitted: (_) => _searchTracking(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_forward,
                      color: Color(0xFF2563EB),
                    ),
                    onPressed: _searchTracking,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Services Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ParcelServiceCard(
                    title: 'Track Order',
                    icon: Icons.search,
                    color: const Color(0xFF2563EB),
                    onTap: _searchTracking,
                  ),
                  const SizedBox(width: 10),
                  ParcelServiceCard(
                    title: 'Place Order',
                    icon: Icons.add_box_outlined,
                    color: const Color(0xFF10B981),
                    onTap: _showCreateParcelSheet,
                  ),
                  const SizedBox(width: 10),
                  ParcelServiceCard(
                    title: 'Live Tracking',
                    icon: Icons.map_outlined,
                    color: const Color(0xFFFFB800),
                    onTap: () {
                      if (activeParcel != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ParcelMapScreen(
                              parcel: activeParcel,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Current Tracking
            Text('CURRENT TRACKING', style: AppText.caption.copyWith(letterSpacing: 1.5)),
            const SizedBox(height: 10),
            CurrentTrackingCard(parcel: activeParcel),
            const SizedBox(height: 24),

            // Recent Orders
            Text('RECENT ORDERS', style: AppText.caption.copyWith(letterSpacing: 1.5)),
            const SizedBox(height: 10),
            if (state.myParcels.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    'No recent orders',
                    style: AppText.caption,
                  ),
                ),
              )
            else
              ...state.myParcels
                  .take(5)
                  .map((parcel) => RecentOrderCard(parcel: parcel))
                  .toList(),
          ],
        ),
      ),
    );
  }
}

class _CreateParcelSheet extends StatelessWidget {
  final TextEditingController senderNameController;
  final TextEditingController receiverNameController;
  final TextEditingController receiverPhoneController;
  final TextEditingController pickupController;
  final TextEditingController destinationController;
  final TextEditingController fareController;
  final VoidCallback onCreate;

  const _CreateParcelSheet({
    required this.senderNameController,
    required this.receiverNameController,
    required this.receiverPhoneController,
    required this.pickupController,
    required this.destinationController,
    required this.fareController,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'SEND PARCEL',
                style: AppText.header.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: senderNameController,
                style: AppText.body,
                decoration: InputDecoration(
                  labelText: 'Sender Name',
                  labelStyle: AppText.caption,
                  prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF2563EB)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: receiverNameController,
                style: AppText.body,
                decoration: InputDecoration(
                  labelText: 'Receiver Name',
                  labelStyle: AppText.caption,
                  prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF2563EB)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: receiverPhoneController,
                style: AppText.body,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Receiver Phone',
                  labelStyle: AppText.caption,
                  prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF2563EB)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pickupController,
                style: AppText.body,
                decoration: InputDecoration(
                  labelText: 'Pickup Stage',
                  labelStyle: AppText.caption,
                  prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF2563EB)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: destinationController,
                style: AppText.body,
                decoration: InputDecoration(
                  labelText: 'Destination Stage',
                  labelStyle: AppText.caption,
                  prefixIcon: const Icon(Icons.flag_outlined, color: Color(0xFF2563EB)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fareController,
                style: AppText.body,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Fare (UGX)',
                  labelStyle: AppText.caption,
                  prefixIcon: const Icon(Icons.payments_outlined, color: Color(0xFF2563EB)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onCreate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'CREATE PARCEL',
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
      ),
    );
  }
}