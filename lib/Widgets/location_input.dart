//this widget handles the input for searching on the Umap screen and others
import 'package:flutter/material.dart';

class LocationInput extends StatelessWidget {
  final String HintText;
  final IconData icon;
  final Color iconColor;
  final TextEditingController controller;
  final VoidCallback ? onTap;

  const LocationInput({
    Key ? key,
    required this.HintText,
    required this.icon,
    required this.iconColor,
    required this.controller,
     this.onTap,
}) : super(key:key);
  @override
  Widget build(BuildContext context){
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(

        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        readOnly: onTap != null,
        onTap: onTap,
        decoration: InputDecoration(
          hintText: HintText,
          hintStyle: TextStyle(color: Colors.grey.shade500,fontSize: 14),
          prefixIcon: Icon(icon,color: iconColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14,horizontal: 16),
        ),
      ),
    );
  }
}