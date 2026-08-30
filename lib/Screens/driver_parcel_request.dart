import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Config/theme.dart';
import '../Providers/parcel_provider.dart';
//import '../models/Parcel_model.dart';
import '../models/parcel_model.dart';

class DriverParcelRequestsScreen extends ConsumerStatefulWidget {
  const DriverParcelRequestsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DriverParcelRequestsScreen> createState() =>
      _DriverParcelRequestsScreenState();
}

class _DriverParcelRequestsScreenState
    extends ConsumerState<DriverParcelRequestsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(parcelProvider.notifier).loadAvailableParcels();
    });
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
        title: const Text('PARCEL REQUESTS'),
        backgroundColor: isDark
            ? SmartStageColors.deepNavy
            : SmartStageColors.deepNavy,
      ),
      body: state.isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: SmartStageColors.electricGreen,
        ),
      )
          : state.availableParcels.isEmpty
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
              'No Parcel Requests',
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
        itemCount: state.availableParcels.length,
        itemBuilder: (context, index) {
          final parcel = state.availableParcels[index];
          return _DriverParcelCard(parcel: parcel);
        },
      ),
    );
  }
}

class _DriverParcelCard extends ConsumerWidget {
  final ParcelModel parcel;

  const _DriverParcelCard({required this.parcel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          Text(
            parcel.trackingCode,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: SmartStageColors.electricGreen,
            ),
          ),
          const SizedBox(height: 8),
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
          const SizedBox(height: 4),
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
          Row(
            children: [
              Text(
                'UGX ${parcel.fare.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: SmartStageColors.gold,
                ),
              ),
              const Spacer(),
              GlowButton(
                text: 'ACCEPT',
                color: SmartStageColors.electricGreen,
                glowColor: SmartStageColors.greenGlow,
                onPressed: () async {
                  await ref
                      .read(parcelProvider.notifier)
                      .acceptParcel(parcel.parcelId);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Parcel accepted!'),
                        backgroundColor: SmartStageColors.electricGreen,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}