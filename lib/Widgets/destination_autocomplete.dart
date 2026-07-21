//this handles the input prediction of text matches
//returning the target location address names
//and pre computed H3 index strings
import 'package:flutter/material.dart';

class DestinationAutocomplete extends StatelessWidget {
  final String mainAddress;
  final String secondaryAddress;
  final VoidCallback onTap;

  const DestinationAutocomplete({
    Key ? key,
    required this.mainAddress,
    required this.secondaryAddress,
    required this.onTap,

}): super(key: key);
  //@override the parent to get some widgets
@override
  Widget build(BuildContext context){
  return ListTile(
    onTap: onTap,
    leading: const CircleAvatar(
      backgroundColor: Color(0xFFF2F4F7),
      child: Icon(Icons.location_on,color: Color(0xFF0056b3)),

    ),
    title: Text(
      mainAddress,
      style: const TextStyle(fontWeight: FontWeight.w600,fontSize: 14),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
    subtitle: Text(
      secondaryAddress,
      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
    dense: true,
  );
}
}