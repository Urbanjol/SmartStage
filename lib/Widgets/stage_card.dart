//this will show how many taxis operating that are available at the moment
//on the stage
import 'package:flutter/material.dart';
import 'package:h3_flutter/h3_flutter.dart';

class StageCard extends StatelessWidget {
  final String StageName;
  final int activeVehiclesCount;
  final String H3index;
  final VoidCallback onTap;

  const StageCard({
    Key ? key,
    required this.StageName,
    required this.activeVehiclesCount,
    required this.H3index,
    required this.onTap,
})  : super(key: key);
  //Build the Widget
@override
  Widget build(BuildContext context){
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16,vertical: 6),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
    child: ListTile(
      onTap: onTap,
      leading: const CircleAvatar(
        backgroundColor: Color(0xFF0056b3),
        child: Icon(Icons.hub,color:Colors.white),

      ),
      title: Text(StageName, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text("H3 Grid Token: $H3index",style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 6),
        decoration: BoxDecoration(
          color: activeVehiclesCount > 0 ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          "$activeVehiclesCount Online",
          style: TextStyle(
            color: activeVehiclesCount > 0 ? Colors.green.shade700 : Colors.orange.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    ),
  );
}
}