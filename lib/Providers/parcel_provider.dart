import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/parcel_model.dart';

class ParcelState {
  final bool isLoading;
  final String? errorMessage;
  final List<ParcelModel> myParcels;
  final ParcelModel? trackedParcel;

  const ParcelState({
    this.isLoading = false,
    this.errorMessage,
    this.myParcels = const [],
    this.trackedParcel,
  });

  ParcelState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<ParcelModel>? myParcels,
    ParcelModel? trackedParcel,
  }) {
    return ParcelState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      myParcels: myParcels ?? this.myParcels,
      trackedParcel: trackedParcel ?? this.trackedParcel,
    );
  }
}

final parcelProvider = NotifierProvider<ParcelNotifier, ParcelState>(() {
  return ParcelNotifier();
});

class ParcelNotifier extends Notifier<ParcelState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  ParcelState build() {
    return const ParcelState();
  }

  String get _currentUserId => _auth.currentUser?.uid ?? '';

  Future<String?> createParcel({
    required String senderName,
    required String receiverName,
    required String receiverPhone,
    required String pickupStage,
    required String destinationStage,
    required double fare,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final parcelRef = _firestore.collection('parcels').doc();
      final trackingCode = 'STG-${DateTime.now().millisecondsSinceEpoch}';

      final parcel = ParcelModel(
        parcelId: parcelRef.id,
        senderId: _currentUserId,
        senderName: senderName,
        receiverName: receiverName,
        receiverPhone: receiverPhone,
        pickupStage: pickupStage,
        destinationStage: destinationStage,
        trackingCode: trackingCode,
        fare: fare,
        createdAt: DateTime.now(),
      );

      await parcelRef.set(parcel.toMap());

      state = state.copyWith(isLoading: false);
      return trackingCode;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to create parcel: $e',
      );
      return null;
    }
  }

  Future<void> loadMyParcels() async {
    state = state.copyWith(isLoading: true);

    try {
      final snapshot = await _firestore
          .collection('parcels')
          .where('sender_id', isEqualTo: _currentUserId)
          .orderBy('created_at', descending: true)
          .get();

      final parcels = snapshot.docs
          .map((doc) => ParcelModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      ))
          .toList();

      state = state.copyWith(isLoading: false, myParcels: parcels);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load parcels: $e',
      );
    }
  }

  Future<void> trackParcel(String trackingCode) async {
    state = state.copyWith(isLoading: true);

    try {
      final snapshot = await _firestore
          .collection('parcels')
          .where('tracking_code', isEqualTo: trackingCode)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final parcel = ParcelModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );

        state = state.copyWith(isLoading: false, trackedParcel: parcel);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Parcel not found',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Tracking failed: $e',
      );
    }
  }
}