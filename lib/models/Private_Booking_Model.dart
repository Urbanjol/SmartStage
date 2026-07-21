//This is the private booking model
import 'package:flutter/foundation.dart';
import 'package:smart_stage/models/Booking_model.dart';

enum BookingStats {
  waiting,
  accepted,
  initiated,
  loading
}
class PrivateBookingModel {
  final String bookingId; //booking id
  final String? driverId; //optional
  final String passengerUid;
  final BookingStats Bstats; //booking status
  final String? taxiId; //optional
  final String pickUpAddress;
  final String destAddress;

 PrivateBookingModel({
   required this.bookingId,
   this.driverId,
   required this.passengerUid,
   this.Bstats = BookingStats.waiting, //containing enum parameters
   //required this.driverId,
   this.taxiId,
   required this.pickUpAddress,
   required this.destAddress,
  });
 //to the server, this is a helper function
 Map<String, dynamic> toMap(){
   return{
     'bookingId':bookingId,
   'driverId': driverId,
     'taxiId' : taxiId,
   'passengerUid':passengerUid,
     'Bstats':Bstats.name,//booking enum
     'pickUpAddress':pickUpAddress,
     'destAddress':destAddress,
 };
}
//from json
factory PrivateBookingModel.fromMap(Map<String,dynamic>map){
   return PrivateBookingModel(
     bookingId: map['bookingId'] ?? '',
   driverId: map['driverId'] ?? '',
   passengerUid: map['passengerUid'] ?? '',
   Bstats: BookingStats.values.byName(map['BookingStats'] ?? ''),
   pickUpAddress: map['pickUpAddress'] ?? '',
   destAddress : map['destAddress'] ?? '',
  );
  }
}