import 'package:flutter/material.dart';

class MorphingActionButton extends StatefulWidget {
  final VoidCallback onScanningStarted;

  const MorphingActionButton({
    Key? key,
    required this.onScanningStarted,
  }) : super(key: key);

  @override
  State<MorphingActionButton> createState() => _MorphingActionButtonState();
}

class _MorphingActionButtonState extends State<MorphingActionButton> with TickerProviderStateMixin {
  bool _isCollapsed = false;
  bool _isCentered = false;
  bool _showRadar = false;

  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
      // Endless loop controller for the pulse ripple effect
      _radarController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2),
      );
    }
  //}

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  void _triggerMorphPipeline() async {
    if (_isCollapsed) return; // Prevent double-taps

    // Phase 1: Collapse the wide button into a circle
    setState(() => _isCollapsed = true);
    await Future.delayed(const Duration(milliseconds: 300));

    // Phase 2: Launch the circle to the screen center
    setState(() => _isCentered = true);
    await Future.delayed(const Duration(milliseconds: 450));

    // Phase 3: Deploy the radar loops
    setState(() => _showRadar = true);
    _radarController.repeat();

    // Fire the callback to notify parent screens to load drivers, etc.
    widget.onScanningStarted();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0056b3);

    return Stack(
      alignment: Alignment.center,
      children: [
        // 1. THE RADAR RIPPLES (Rendered behind the anchor)
        if (_showRadar)
          ...List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _radarController,
              builder: (context, child) {
                // Stagger each ripple wave sequentially
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

        // 2. THE MORPHING BUTTON & LAUNCHER FLIGHT FRAME
        AnimatedAlign(
          duration: const Duration(milliseconds: 450),
          curve: Curves.fastOutSlowIn, // Premium presentation easing path
          alignment: _isCentered ? Alignment.center : Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: _isCentered ? 0 : 24.0),
            child: GestureDetector(
              onTap: _triggerMorphPipeline,
              /////////////////////
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: _isCollapsed ? 56 : MediaQuery.of(context).size.width * 0.85,
                height: 56,
                // REMOVED: elevation: _isCollapsed ? 8 : 2,
                decoration: BoxDecoration(
                  color: _isCollapsed && isDarkMode ? Colors.orange : primaryColor,
                  borderRadius: BorderRadius.circular(_isCollapsed ? 28 : 14),
                  boxShadow: [
                    BoxShadow(
                      // FIXED: The shadow dynamically deepens when collapsed to simulate elevation lift!
                      color: Colors.black.withOpacity(isDarkMode ? 0.4 : 0.15),
                      blurRadius: _isCollapsed ? 12 : 6,
                      spreadRadius: _isCollapsed ? 2 : 0,
                      offset: _isCollapsed ? const Offset(0, 6) : const Offset(0, 3),
                    )
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
              //////////////////

            ),
          ),
        ),
      ],
    );
  }
}