import 'package:flutter/material.dart';

class ProgressSteps extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  const ProgressSteps({
    super.key,
    required this.totalSteps,
    this.currentStep = 1,
  }) : assert(currentStep <= totalSteps && currentStep > 0,
            'Current step must be between 1 and totalSteps');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Paso $currentStep de $totalSteps',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            // Barra de fondo
            Container(
              height: 8, // Barra más gruesa
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Barra de progreso
            FractionallySizedBox(
              widthFactor: currentStep / totalSteps,
              child: Container(
                height: 8, // Barra más gruesa
                decoration: BoxDecoration(
                  color: const Color(0xFF1E5E9E), // Color específico
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
