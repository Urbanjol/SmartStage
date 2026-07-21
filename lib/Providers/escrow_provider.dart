//encapsulate the escrow engine, this gives us global,reactive visibility into financial status fields
//from any future system module'
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Services/momo_escrow.dart';

//Provides our application with an instance of the backend payment engine
final momoEscrowServiceProvider = Provider<MomoEscrow>((ref){
  return MomoEscrow();
});
//Realtime stream provider tracking state of a specific transaction (e.g..,verifying if funds
//are locked yet)
final transactionStatusProvider = StreamProvider.family<PaymentStatus,String>((ref,bookingId){
  return FirebaseFirestore.instance
      .collection('escrow_transactions')
      .doc(bookingId)
      .snapshots()
      .map((snapshot){
        if(!snapshot.exists) return PaymentStatus.failed;
        final statusStr = snapshot.data()?['status'] as String? ?? '';
        return PaymentStatus.values.byName(statusStr);
  });
});