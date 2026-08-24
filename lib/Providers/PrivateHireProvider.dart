import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/Booking_model.dart';

// ============================================================
// STATE
// ============================================================
class PrivateHireState {
  final bool isLoadingBookings;
  final bool isLoadingDrivers;
  final bool isCreatingBooking;
  final String? errorMessage;
  final List<BookingModel> myBookings;
  final List<BookingModel> nearbyBookings;
  final List<Map<String, dynamic>> nearbyDrivers;

  const PrivateHireState({
    this.isLoadingBookings = false,
    this.isLoadingDrivers = false,
    this.isCreatingBooking = false,
    this.errorMessage,
    this.myBookings = const [],
    this.nearbyBookings = const [],
    this.nearbyDrivers = const [],
  });

  PrivateHireState copyWith({
    bool? isLoadingBookings,
    bool? isLoadingDrivers,
    bool? isCreatingBooking,
    String? errorMessage,
    List<BookingModel>? myBookings,
    List<BookingModel>? nearbyBookings,
    List<Map<String, dynamic>>? nearbyDrivers,
  }) {
    return PrivateHireState(
      isLoadingBookings: isLoadingBookings ?? this.isLoadingBookings,
      isLoadingDrivers: isLoadingDrivers ?? this.isLoadingDrivers,
      isCreatingBooking: isCreatingBooking ?? this.isCreatingBooking,
      errorMessage: errorMessage ?? this.errorMessage,
      myBookings: myBookings ?? this.myBookings,
      nearbyBookings: nearbyBookings ?? this.nearbyBookings,
      nearbyDrivers: nearbyDrivers ?? this.nearbyDrivers,
    );
  }
}

// ============================================================
// PROVIDER
// ============================================================
final privateHireProvider =
NotifierProvider<PrivateHireNotifier, PrivateHireState>(() {
  return PrivateHireNotifier();
});

class PrivateHireNotifier extends Notifier<PrivateHireState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  PrivateHireState build() {
    return const PrivateHireState();
  }

  String get _currentUserId => _auth.currentUser?.uid ?? '';

  // ============================================================
  // CREATE BOOKING
  // ============================================================
  Future<String?> createBooking({
    required String pickUpAddress,
    required String destinationAddress,
    required String pickUph3,
    required String destinationH3,
    required EventType eventType,
    required DateTime eventDate,
    required int passengerCount,
    required String eventDescription,
    double fareAmount = 0,
  }) async {
    state = state.copyWith(
      isCreatingBooking: true,
      errorMessage: null,
    );

    try {
      final bookingRef = _firestore.collection('bookings').doc();
      final bookingId = bookingRef.id;

      final booking = BookingModel(
        bookingId: bookingId,
        passengerUid: _currentUserId,
        bookingTime: DateTime.now(),
        eventDate: eventDate,
        pickUph3: pickUph3,
        destinationH3: destinationH3,
        pickUpAddress: pickUpAddress,
        destinationAddress: destinationAddress,
        event: eventType,
        passengerCount: passengerCount,
        eventDescription: eventDescription,
        fareAmount: fareAmount,
        status: BookingStatus.searching,
        paymentStatus: 'UNPAID',
      );

      await bookingRef.set(booking.toMap());

      state = state.copyWith(isCreatingBooking: false);
      return bookingId;
    } catch (e) {
      state = state.copyWith(
        isCreatingBooking: false,
        errorMessage: 'Failed to create booking: $e',
      );
      return null;
    }
  }

  // ============================================================
  // LOAD MY BOOKINGS
  // ============================================================
  Future<void> loadMyBookings() async {
    state = state.copyWith(isLoadingBookings: true, errorMessage: null);

    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('passengerUid', isEqualTo: _currentUserId)
          .orderBy('bookingTime', descending: true)
          .get();

      final bookings = snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data()))
          .toList();

      state = state.copyWith(
        isLoadingBookings: false,
        myBookings: bookings,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingBookings: false,
        errorMessage: 'Failed to load bookings: $e',
      );
    }
  }

  // ============================================================
  // LOAD NEARBY BOOKINGS
  // ============================================================
  Future<void> loadNearbyBookings({String? h3Index}) async {
    state = state.copyWith(isLoadingBookings: true, errorMessage: null);

    try {
      Query query = _firestore
          .collection('bookings')
          .where('status', isEqualTo: 'searching')
          .limit(20);

      if (h3Index != null && h3Index.isNotEmpty) {
        query = query.where('pickUph3', isEqualTo: h3Index);
      }

      final snapshot = await query.get();

      final bookings = snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data() as Map<String, dynamic>))
          .where((booking) => booking.passengerUid != _currentUserId)
          .toList();

      state = state.copyWith(
        isLoadingBookings: false,
        nearbyBookings: bookings,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingBookings: false,
        errorMessage: 'Failed to load nearby bookings: $e',
      );
    }
  }

  // ============================================================
  // LOAD NEARBY DRIVERS
  // ============================================================
  Future<void> loadNearbyDrivers({double? lat, double? lng}) async {
    state = state.copyWith(isLoadingDrivers: true, errorMessage: null);

    try {
      Query query = _firestore
          .collection('matatus')
          .where('seat_state', isEqualTo: 'space_available')
          .limit(30);

      final snapshot = await query.get();

      final drivers = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'matatu_id': doc.id,
          'plate': data['plate'] ?? 'Unknown',
          'seat_state': data['seat_state'] ?? 'unknown',
          'seats_available': data['seats_available'] ?? 0,
          'route': data['route'] ?? [],
          'rating': data['rating'] ?? 4.5,
          'driver_name': data['driver_name'] ?? 'SmartStage Driver',
        };
      }).toList();

      state = state.copyWith(
        isLoadingDrivers: false,
        nearbyDrivers: drivers,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingDrivers: false,
        errorMessage: 'Failed to load drivers: $e',
      );
    }
  }

  // ============================================================
  // DRIVER INTERESTED
  // ============================================================
  Future<void> driverInterested(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': BookingStatus.driver_interested.name,
        'driverUid': _currentUserId,
      });
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to update booking: $e',
      );
    }
  }

  // ============================================================
  // CANCEL BOOKING
  // ============================================================
  Future<void> cancelBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': BookingStatus.cancelled.name,
      });
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to cancel booking: $e',
      );
    }
  }
}