import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Phone number verification
  Future<void> sendOTP(
      String phoneNumber, {
        required Function(String, int?) codeSent,
        required Function(FirebaseAuthException) verificationFailed,
      }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: verificationFailed,
      codeSent: (String verificationId, int? resendToken) {
        codeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  //////////////////////////////////////////////////
  Future<void> sendOTP2(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        throw e;
      },
      codeSent: (String verificationId, int? resendToken) {
        // Store verificationId for later use
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // Verify OTP
  Future<UserCredential> verifyOTP(
      String verificationId, String smsCode) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return await _auth.signInWithCredential(credential);
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Check if user exists in Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  // Create user in Firestore
  Future<void> createUser(String uid, String name, String phone,
      {List<String> roles = const ['passenger']}) async {
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'phone': phone,
      'roles': roles,
      'created_at': FieldValue.serverTimestamp(),
      'is_verified': false,
    });
  }
}