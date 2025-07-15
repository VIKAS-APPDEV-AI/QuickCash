import 'package:flutter/material.dart';

// Custom Animated Container Widget
class AnimatedContainerWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve fadeCurve;
  final Curve slideCurve;
  final Offset slideBegin;
  final bool autoPlay;
  final VoidCallback? onAnimationComplete;

  const AnimatedContainerWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.fadeCurve = Curves.easeIn,
    this.slideCurve = Curves.easeOut,
    this.slideBegin = const Offset(-1.0, 0.0), // Default slide from left
    this.autoPlay = true,
    this.onAnimationComplete,
  });

  @override
  State<AnimatedContainerWidget> createState() => _AnimatedContainerWidgetState();
}

class _AnimatedContainerWidgetState extends State<AnimatedContainerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.fadeCurve),
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.slideBegin,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.slideCurve));

    if (widget.autoPlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.forward().then((_) {
          widget.onAnimationComplete?.call();
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Method to manually trigger animation
  void triggerAnimation() {
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}