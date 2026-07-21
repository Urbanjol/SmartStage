import 'package:cloud_firestore/cloud_firestore.dart';

import '../Services/booking_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//Dependency injection provider
final bookingStateMachineProvider = Provider<BookingService>((ref){
  return BookingService();
});
//real time booking provider for tracking a specific active trip's change
final activeTripStreamProvider = StreamProvider.family<DocumentSnapshot, String>((ref, bookingId){
  return FirebaseFirestore.instance.collection('bookings').doc(bookingId).snapshots();
});
//Real time stream provider for tracking private event negotiations
final privateEventStreamProvider = StreamProvider.family<DocumentSnapshot, String>((ref,privateBookingId){
  return FirebaseFirestore.instance.collection('bookings').doc(privateBookingId).snapshots();
});
