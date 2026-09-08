import 'package:flutter/material.dart';

class MorphingActionButton extends StatefulWidget {
  final VoidCallback onScanningStarted;
  final bool isScanning;

  const MorphingActionButton({
    Key? key,
    required this.onScanningStarted,
    this.isScanning = false,
  }) : super(key: key);

  @override
  State<MorphingActionButton> createState() => _MorphingActionButtonState();
}

class _MorphingActionButtonState extends State<MorphingActionButton>
    with TickerProviderStateMixin {
  bool _isCollapsed = false;
  bool _isCentered = false;
  bool _showRadar = false;

  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MorphingActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isScanning && !widget.isScanning) {
      _resetButton();
    }
  }

  void _resetButton() {
    _radarController.stop();
    _radarController.reset();

    setState(() {
      _showRadar = false;
      _isCentered = false;
      _isCollapsed = false;
    });
  }

  void _triggerMorphPipeline() async {
    if (_isCollapsed) return;

    setState(() => _isCollapsed = true);
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() => _isCentered = true);
    await Future.delayed(const Duration(milliseconds: 450));

    setState(() => _showRadar = true);
    _radarController.repeat();

    widget.onScanningStarted();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF2563EB);

    return Stack(
      alignment: Alignment.center,
      children: [
        if (_showRadar && widget.isScanning)
          ...List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _radarController,
              builder: (context, child) {
                double progress = (_radarController.value + (index / 3)) % 1.0;
                return Container(
                  width: progress * 320,
                  height: progress * 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isDarkMode ? Colors.orange : primaryColor)
                        .withOpacity((1.0 - progress) * 0.25),
                  ),
                );
              },
            );
          }),

        AnimatedAlign(
          duration: const Duration(milliseconds: 450),
          curve: Curves.fastOutSlowIn,
          alignment: _isCentered ? Alignment.center : Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: _isCentered ? 0 : 24.0),
            child: GestureDetector(
              onTap: _triggerMorphPipeline,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: _isCollapsed
                    ? 56
                    : MediaQuery.of(context).size.width * 0.85,
                height: 56,
                decoration: BoxDecoration(
                  color: _isCollapsed && isDarkMode
                      ? Colors.orange
                      : primaryColor,
                  borderRadius: BorderRadius.circular(_isCollapsed ? 28 : 14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDarkMode ? 0.4 : 0.15),
                      blurRadius: _isCollapsed ? 12 : 6,
                      spreadRadius: _isCollapsed ? 2 : 0,
                      offset: _isCollapsed ? const Offset(0, 6) : const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: AnimatedCrossFade(
                  duration: const Duration(milliseconds: 150),
                  crossFadeState: _isCollapsed
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const Text(
                    "Scan SmartStage Rings",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  secondChild: const Icon(
                    Icons.radar,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}