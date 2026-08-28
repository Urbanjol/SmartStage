import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Config/theme.dart';
import '../Providers/parcel_provider.dart';
import '../models/parcel_model.dart';

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
        onCreate: () {
          ref.read(parcelProvider.notifier).createParcel(
            senderName: _senderNameController.text.trim(),
            receiverName: _receiverNameController.text.trim(),
            receiverPhone: _receiverPhoneController.text.trim(),
            pickupStage: _pickupController.text.trim(),
            destinationStage: _destinationController.text.trim(),
            fare: double.tryParse(_fareController.text.trim()) ?? 0,
          );
        },
      ),
    );
  }

  void _showTrackParcelSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? SmartStageColors.navyCard
              : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        padding: const EdgeInsets.all(24),
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
            const SizedBox(height: 20),
            const Text(
              'TRACK PARCEL',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: SmartStageColors.deepNavy,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _trackingController,
              decoration: const InputDecoration(
                labelText: 'Tracking Code',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 20),
            GlowButton(
              text: 'TRACK',
              color: SmartStageColors.gold,
              glowColor: SmartStageColors.goldGlow,
              onPressed: () {
                Navigator.pop(context);
                ref
                    .read(parcelProvider.notifier)
                    .trackParcel(_trackingController.text.trim());
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(parcelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? SmartStageColors.darkBackground
          : SmartStageColors.lightBackground,
      appBar: AppBar(
        title: const Text('PARCEL DELIVERY'),
        backgroundColor: isDark
            ? SmartStageColors.deepNavy
            : SmartStageColors.deepNavy,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showTrackParcelSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Create Parcel Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: GlowButton(
              text: 'SEND A PARCEL',
              color: SmartStageColors.gold,
              glowColor: SmartStageColors.goldGlow,
              icon: Icons.add_box_outlined,
              onPressed: _showCreateParcelSheet,
            ),
          ),
          const SizedBox(height: 10),

          // Parcel List
          Expanded(
            child: state.isLoading
                ? const Center(
              child: CircularProgressIndicator(
                color: SmartStageColors.electricGreen,
              ),
            )
                : state.myParcels.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: isDark
                        ? SmartStageColors.greyDark
                        : SmartStageColors.greyLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Parcels Yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? SmartStageColors.greyMid
                          : SmartStageColors.greyDark,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.myParcels.length,
              itemBuilder: (context, index) {
                final parcel = state.myParcels[index];
                return _ParcelCard(parcel: parcel);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ParcelCard extends StatelessWidget {
  final ParcelModel parcel;

  const _ParcelCard({required this.parcel});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? SmartStageColors.navyCard : SmartStageColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : SmartStageColors.greyLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                parcel.trackingCode,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: SmartStageColors.electricGreen,
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: SmartStageColors.purpleGlow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  parcel.statusLabel,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: SmartStageColors.deepNavy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: SmartStageColors.electricGreen,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  parcel.pickupStage,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? SmartStageColors.white
                        : SmartStageColors.deepNavy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.flag_outlined,
                size: 16,
                color: SmartStageColors.gold,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  parcel.destinationStage,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? SmartStageColors.white
                        : SmartStageColors.deepNavy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'UGX ${parcel.fare.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: SmartStageColors.gold,
            ),
          ),
        ],
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
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? SmartStageColors.navyCard
            : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
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
                color: SmartStageColors.deepNavy,
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
              color: SmartStageColors.gold,
              glowColor: SmartStageColors.goldGlow,
              onPressed: () {
                Navigator.pop(context);
                onCreate();
              },
            ),
          ],
        ),
      ),
    );
  }
}