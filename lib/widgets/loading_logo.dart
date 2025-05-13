import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Widget reutilizable: logo con aro giratorio animado
class LoadingLogo extends StatefulWidget {
  final double size;
  const LoadingLogo({super.key, required this.size});

  @override
  _LoadingLogoState createState() => _LoadingLogoState();
}

class _LoadingLogoState extends State<LoadingLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: widget.size,
                height: widget.size,
                child: CustomPaint(
                  painter: LoadingPainter(
                    progress: _controller.value,
                    strokeWidth: 10.0,
                    startColor: const Color(0xFF38A8E0),
                    endColor: const Color(0xFFBAE2F5),
                  ),
                ),
              ),
              Image.asset(
                'assets/images/NewLogoJustE.png',
                width: widget.size * 0.5,
                fit: BoxFit.contain,
              ),
            ],
          );
        },
      ),
    );
  }
}

class LoadingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color startColor;
  final Color endColor;

  LoadingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.startColor,
    required this.endColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      colors: [startColor, endColor],
      stops: [0.0, 1.0],
      transform: GradientRotation(2 * math.pi * progress - math.pi / 2),
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant LoadingPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        strokeWidth != oldDelegate.strokeWidth ||
        startColor != oldDelegate.startColor ||
        endColor != oldDelegate.endColor;
  }
}
