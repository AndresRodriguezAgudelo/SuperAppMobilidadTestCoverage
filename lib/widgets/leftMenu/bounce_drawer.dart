import 'package:flutter/material.dart';
import 'dart:ui';

class BounceDrawer extends StatefulWidget {
  final Widget child;
  final Duration openDuration;
  final Duration fadeDuration;

  const BounceDrawer({
    super.key,
    required this.child,
    this.openDuration = const Duration(milliseconds: 250),
    this.fadeDuration = const Duration(milliseconds: 800),
  });

  @override
  State<BounceDrawer> createState() => _BounceDrawerState();
}

class _BounceDrawerState extends State<BounceDrawer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.fadeDuration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _controller.forward();
      }
    });
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
        return Stack(
          children: [
            widget.child,
            Positioned.fill(
              child: Container(
                color: Colors.white,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10 * (1 - _fadeAnimation.value), sigmaY: 10 * (1 - _fadeAnimation.value)),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ],
        );
      },
      child: widget.child,
    );
  }
}
