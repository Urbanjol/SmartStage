//this button is for confirming and lock escrow
import 'package:flutter/material.dart';

class PrimaryActionButton extends StatelessWidget {
final String label;
final VoidCallback? onTap; //optional button tapping
final bool isLoading; //loading circle

const PrimaryActionButton({
  Key? key,
  required this.label,
  required this.onTap,
  this.isLoading = false,

}) : super(key: key);
@override
Widget build(BuildContext context){
  return Container (
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: ElevatedButton(
        onPressed: isLoading ? null: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0056b3),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
      child: isLoading ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      ) : Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,letterSpacing: 0.5),
      ),
    ),
    );
}
}
 // )
//}
//}