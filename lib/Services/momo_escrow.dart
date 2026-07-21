import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

//create the enum messages that will be used to track the payments
enum PaymentStatus {
  pending,
  lockedInEscrow,
  disbursedToDriver,
  refundedToPassenger,
  failed
}
//now we write our class for momo
class MomoEscrow {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //MOCK ENDPOINTS FOR NOW
  static const String _mtnApiUrl = 'https://sandbox.momodeveloper.mtn.com/collection/v1_0/requesttopay';
  static const String _airtelApiUrl = 'https://airtel.developer.com/blabla';

//trigger directly a USSD push prompt   to the passenger's phone
//Input their pin, funds are pulled into smartstage escrow account
  Future<bool> initiateEscrowCollection({
    required String bookingId,
    required String phoneNumber,
    required double amountUGX,
    required bool isMTN,
  }) async {
    final paymentDocRef = _db.collection('escrow_transactions').doc(bookingId);
    //Initialize pending financial state inside the database
    await paymentDocRef.set({
      'bookingId': bookingId,
      'phoneNumber': phoneNumber,
      'amount': isMTN ? 'MTN' : 'Airtel',
      'status': PaymentStatus.pending.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
    try {
      //fire the programmatic network request for the telecom gateway
      final response = await http.post(
        Uri.parse(isMTN ? _mtnApiUrl : _airtelApiUrl),
        headers: {
          'Authorization': 'Bearer token telecom access',
          'X-Target-Environment': 'sandbox',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({ //here we need to encode not decode..
          "amount": amountUGX.toString(),
          "currency": "UGX",
          "payer": {"partyIdType": "MSISDN", "partyId": phoneNumber},
          "payerMessage": "Locking payment for SmartStage trip",
          "payeeNote": "SmartStage Escrow Deposit"
        }),
      );
      if (response.statusCode == 202) {
        //HTTP 202 Accepted means the telecom has pushed the authorization prompt to the phone
        await paymentDocRef.update({
          'status': PaymentStatus.lockedInEscrow.name,
          'telecomExternalId': jsonDecode(
              response.body)['financialTransactionId'] ?? '',
        });
        return true;
      } else {
        await paymentDocRef.update({
          'status': PaymentStatus.failed.name
        });
        return false;
      }
    } catch (e) {
      await paymentDocRef.update({
        'status': PaymentStatus.failed.name
      });
      throw Exception('Mobile Money Gateway Communication Failure: $e');
    }
  }
//Trigger programmatically the state machine when BookingStatus.completed is hit.
//This flushes the Escrow balance out of
// SmartStage and directly into the driver's wallet.
Future<void>releaseEscrowToDriver(String bookingId,String driverId) async {
    final transactionRef = _db.collection('escrow_transactions').doc(bookingId);
    final driverRef = _db.collection('drivers').doc(driverId);
    await _db.runTransaction((transaction) async {
      final txSnapshot = await transaction.get(transactionRef);
      if(!txSnapshot.exists) throw Exception("Transaction record missing.");
      final currentStatus = txSnapshot.data()?['status'] as String?;
      final amount = txSnapshot.data()?['amount'] as double? ?? 0.0;
      if(currentStatus == PaymentStatus.lockedInEscrow.name){
        //1.Update Escrow contract to fully closed
        transaction.update(transactionRef, {'status':PaymentStatus.disbursedToDriver.name});
        //2.Perform safe arithmetic incrementation on driver balance field inside database
        transaction.update(driverRef, {'walletBalance':FieldValue.increment(amount),
        });
      }else {
        throw Exception("Funds cannot be released.Current stats: $currentStatus");
      }
    });
}
}