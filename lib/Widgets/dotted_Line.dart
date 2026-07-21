import 'package:flutter/material.dart';

class DottedLine extends CustomPainter{
final Color color;
DottedLine({required this.color});

@override
void paint(Canvas canvas, Size size){
  double dashHeight = 4, dashSpace = 3, startY = 0;
  final paint = Paint()
    ..color = color
    ..strokeWidth = size.width
    ..style = PaintingStyle.stroke;

  while (startY < size.height) {
    canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
    startY += dashHeight + dashSpace;
  }
}

@override
bool shouldRepaint(CustomPainter oldDelegate) => false;
}
