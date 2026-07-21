import 'package:flutter/material.dart';

//this widget will show different prices of routes for the taxi
//like the billboard
class PriceTag extends StatelessWidget {
  //inputs
  final String routeDestination;
  final double priceUGX;

  const PriceTag({
    Key ? key,
    required this.routeDestination,
    required this.priceUGX,
  }) : super(key: key);

  //build
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF005b3),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset (0, 2),

              ),
            ], //taxi blue

          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                routeDestination.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                "${priceUGX.toInt()} UGX",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        //Tiny downward triangle pointing to the taxi
        CustomPaint(
          size: const Size(10, 5),
          painter: TrianglePainter(color: const Color(0xFF0056b3)),
        ),
      ],
    );
  }
}
class TrianglePainter extends CustomPainter{
  final Color color;
  TrianglePainter({
    required this.color
});
  @override
  void paint(Canvas canvas, Size size){
    final paint =Paint()..color = color;
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width/2, size.height);
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path,paint);


  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
//}