import 'package:smart_stage/models/Booking_model.dart';

import '../models/User_model.dart';
import '../models/Taxi_model.dart';
import '../models/Private_Booking_Model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  //initiate a standard point to point ride transaction
Future<void>createImmediateBooking(BookingModel booking) async{
  await _db.collection('bookings')
      .doc(booking.bookingId).set(booking.toMap());
}
//Atomically assign drivers to an immediate ride using a transaction
Future<bool>acceptImmediateBooking(String bookingId,String driverId) async{
  final bookingRef = _db.collection('bookings').doc(bookingId);
  return _db.runTransaction((transaction) async {
    final snapShot = await transaction.get(bookingRef);
    if(!snapShot.exists) return false;
    final currentStatus = snapShot.data()?['status'] as String?;
    //Ensure the ride hasnt already been taken by another matatu/taxi
    if(currentStatus == BookingStatus.pending.name){
      transaction.update(bookingRef, {
        'driverId':driverId,
        'status':BookingStatus.matched.name,
        'assignedAt':FieldValue.serverTimestamp(),
      });
      return true;
    }
    return false; //already accepted or cancelled
  });
}
//private event logistics machine
//A passenger submits a form eg coaster van hire to masaka
  //i have to create the privateBookingModel
  //and separate it from the bookingModel.
Future<void>initializePrivateBooking(PrivateBookingModel privateBooking) async {
  await _db.collection('privateBookings')
      .doc(privateBooking.bookingId)
      .set(privateBooking.toMap());
}
 //Allow a driver to submit an operational counter -offer  due to road conditions
//fuel overheads or multiday shifts
Future<void>submitDriverCounterOffer({required String privateBookingId,
required String driverId, required double counterPriceUGX,})async{
  final bookingRef = _db.collection('privateBookings').doc(privateBookingId);
  await _db.runTransaction((transaction) async{
    final snapshot = await transaction.get(bookingRef);
    if(!snapshot.exists) throw Exception("Booking entry not found");
    //Append counter offer details while keeping the transaction open
    transaction.update(bookingRef, {
      'assignedDriverId':driverId,
      'negotiatedPrice':counterPriceUGX,
      //keep escrow for momo off until the passenger signs off on the updated cost
      'isMomoEscrowLocked':false,
    });
  });
  //passenger approves the counterPrice, this advances the state machine and flags the system to
  //trigger momo billing event
  Future<void>passengerConfirmNegotiation(String privateBookingId) async {
    await _db.collection('privateBookings').doc(privateBookingId).update({
      'negotiationSettled': true,
    });
    //complete and finalize the event when the procession ends
    Future<void>completePrivateEvent(String privateBookingId) async {
      await _db.collection('privateBookings').doc(privateBookingId).update(
          {
            'isMoMoEscrowLocked':false,
            'eventCompleted':true,
            'completedAt':FieldValue.serverTimestamp(),
          });
    }
  }
}
}