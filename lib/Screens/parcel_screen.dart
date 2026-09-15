import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Config/theme.dart';
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
              const SnackBar(
                content: Text('Please fill all required fields'),
                backgroundColor: SmartStageColors.red,
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
        title: const Text(
          'PARCEL CREATED!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: SmartStageColors.primaryBlue,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Your parcel has been created.'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SmartStageColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                trackingCode,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: SmartStageColors.primaryBlue,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Share this code with the receiver',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(
                color: SmartStageColors.primaryBlue,
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
        title: const Text('PARCEL SERVICES'),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search,
                    color: SmartStageColors.primaryBlue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _trackingController,
                      decoration: const InputDecoration(
                        hintText: 'Enter tracking code',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _searchTracking(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_forward,
                      color: SmartStageColors.primaryBlue,
                    ),
                    onPressed: _searchTracking,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

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
                  const SizedBox(width: 8),
                  ParcelServiceCard(
                    title: 'Place Order',
                    icon: Icons.add_box_outlined,
                    color: const Color(0xFF10B981),
                    onTap: _showCreateParcelSheet,
                  ),
                  const SizedBox(width: 8),
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
            const SizedBox(height: 20),

            // Current Tracking
            const Text(
              'CURRENT TRACKING',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            CurrentTrackingCard(parcel: activeParcel),
            const SizedBox(height: 20),

            // Recent Orders
            const Text(
              'RECENT ORDERS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            if (state.myParcels.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'No recent orders',
                    style: TextStyle(color: Colors.grey),
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
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
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
                    color: SmartStageColors.greyLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'SEND PARCEL',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: senderNameController,
                decoration: const InputDecoration(
                  labelText: 'Sender Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: receiverNameController,
                decoration: const InputDecoration(
                  labelText: 'Receiver Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: receiverPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Receiver Phone',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pickupController,
                decoration: const InputDecoration(
                  labelText: 'Pickup Stage',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: destinationController,
                decoration: const InputDecoration(
                  labelText: 'Destination Stage',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fareController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Fare (UGX)',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
              ),
              const SizedBox(height: 24),
              GlowButton(
                text: 'CREATE PARCEL',
                color: SmartStageColors.primaryBlue,
                glowColor: SmartStageColors.primaryBlue.withOpacity(0.4),
                onPressed: onCreate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}