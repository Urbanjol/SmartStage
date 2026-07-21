//this handles the verification widget
//for trust and achieved things

import 'package:flutter/material.dart';
class VerificationBadge extends StatelessWidget {
  //variables
  final bool isVerified;
  final String title;

  const VerificationBadge({
    Key ? key,
    required this.isVerified,
    required this.title,
}) : super(key: key);

  //widget
@override
  Widget build(BuildContext context){
  return Container(
padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: isVerified ? Colors.green.withOpacity(0.08) : Colors.red.withOpacity(0.08),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: isVerified ? Colors.green.shade300 : Colors.red.shade300),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isVerified ? Icons.verified_sharp : Icons.gpp_bad,
          color: isVerified ? Colors.green.shade700: Colors.red.shade700,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: isVerified ? Colors.green.shade900 : Colors.red.shade900,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    ),
  );
}
}