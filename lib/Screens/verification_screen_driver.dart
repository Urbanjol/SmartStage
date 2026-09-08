import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Config/theme.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<VerificationScreen> createState() =>
      _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  bool _isSubmitting = false;
  String _licenseNumber = '';
  String _nationalIdNumber = '';

  Future<void> _submitVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_licenseNumber.isEmpty || _nationalIdNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: SmartStageColors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('verification_requests')
          .add({
        'driver_id': user.uid,
        'license_number': _licenseNumber,
        'national_id_number': _nationalIdNumber,
        'status': 'pending',
        'paid': false,
        'created_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification submitted!'),
            backgroundColor: SmartStageColors.electricGreen,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('GET VERIFIED'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.verified,
                    color: Colors.white,
                    size: 40,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verified Driver',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Get the blue tick and stand out to passengers',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'REQUIRED DETAILS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: (value) => _licenseNumber = value,
              decoration: const InputDecoration(
                labelText: 'Driving License Number',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: (value) => _nationalIdNumber = value,
              decoration: const InputDecoration(
                labelText: 'National ID Number',
                prefixIcon: Icon(Icons.credit_card_outlined),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'VERIFICATION FEE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF2563EB).withOpacity(0.2),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.payments_outlined,
                    color: Color(0xFFFFB800),
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'UGX 2,000',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Spacer(),
                  Text(
                    'One-time',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GlowButton(
              text: _isSubmitting ? 'SUBMITTING...' : 'SUBMIT FOR VERIFICATION',
              color: SmartStageColors.primaryBlue,
              glowColor: SmartStageColors.primaryBlue.withOpacity(0.4),
              icon: Icons.verified_outlined,
              onPressed: _isSubmitting ? () {} : _submitVerification,
            ),
          ],
        ),
      ),
    );
  }
}