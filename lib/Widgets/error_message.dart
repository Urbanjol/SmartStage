//this will handle the error looks
//we dont want the errors to scare users
import 'package:flutter/material.dart';
class ErrorMessage extends StatelessWidget {
  //our variables
  final String errorMessage;
  final VoidCallback onRetry;

  ErrorMessage({
    Key ? key,
    required this.errorMessage,
    required this.onRetry,
}): super(key: key);
  //start the widget
@override
  Widget build(BuildContext context){
  return Container(
    //margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 5),
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.red.shade50,
      borderRadius:BorderRadius.circular(12),
      border: Border.all(color: Colors.red.shade100),

    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(Icons.error_outline,color: Colors.red.shade700),
            const SizedBox(width: 12),
            Expanded(
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.w500),
                ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(onPressed: onRetry,
              icon: const Icon(Icons.refresh,size: 16),
              label: const Text("Retry Connection"),
              style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
          ),
        ),
      ],
    ),
  );
}
}