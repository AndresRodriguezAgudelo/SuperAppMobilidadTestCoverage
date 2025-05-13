import 'package:flutter/material.dart';
import 'dart:math' as math;

class Loading extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const Loading({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.white,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Aro giratorio con degradado
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.21, // Reducido de 0.4 a 0.3
                    height: MediaQuery.of(context).size.width * 0.21, // Reducido de 0.4 a 0.3
                    child: AnimatedLoadingRing(),
                  ),
                  // Logo centrado
                  Image.asset(
                    'assets/images/NewLogoJustE.png',
                    width: MediaQuery.of(context).size.width * 0.10, // Reducido de 0.20 a 0.15
                    fit: BoxFit.contain,
                  ),
                  // Mensaje opcional debajo del logo
                ],
              ),
            ),
          ),
        if (isLoading && message != null)
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.32,
            left: 0,
            right: 0,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  message!,
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Widget animado para el aro giratorio (como en SplashScreen)
class AnimatedLoadingRing extends StatefulWidget {
  const AnimatedLoadingRing({super.key});

  @override
  _AnimatedLoadingRingState createState() => _AnimatedLoadingRingState();
}

class _AnimatedLoadingRingState extends State<AnimatedLoadingRing> with SingleTickerProviderStateMixin {
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: LoadingPainter(
            progress: _controller.value,
            strokeWidth: 10.0,
            startColor: const Color(0xFF38A8E0),
            endColor: const Color(0xFFBAE2F5),
          ),
        );
      },
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
      stops: const [0.0, 1.0],
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
  bool shouldRepaint(LoadingPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      strokeWidth != oldDelegate.strokeWidth ||
      startColor != oldDelegate.startColor ||
      endColor != oldDelegate.endColor;
}
