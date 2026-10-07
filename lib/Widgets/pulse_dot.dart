import 'package:flutter/material.dart';

class PulseDot extends StatefulWidget {
  final Color color;
  final double size;

  const PulseDot({
    Key? key,
    required this.color,
    this.size = 10,
  }) : super(key: key);

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(0.5 + (_controller.value * 0.5)),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(_controller.value * 0.6),
                blurRadius: widget.size * _controller.value * 2,
                spreadRadius: widget.size * _controller.value * 0.3,
              ),
            ],
          ),
        );
      },
    );
  }
}