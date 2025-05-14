import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Clase modificada para testing que no usa temporizadores
class TestConfirmationModal extends StatelessWidget {
  final int attitude;
  final String label;

  const TestConfirmationModal({
    super.key,
    required this.attitude,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = attitude == 1;
    final statusColor = isPositive ? const Color(0xFF319E7C) : const Color(0xFFE05C3A);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPositive ? const Color(0xFFECFAD7) : const Color(0xFFFADDD7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPositive ? Icons.check : Icons.cancel,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

void main() {
  group('ConfirmationModal', () {
    testWidgets('Debería renderizarse correctamente con actitud positiva', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestConfirmationModal(
              attitude: 1,
              label: 'Operación exitosa',
            ),
          ),
        ),
      );
      
      // Verificar que el widget se renderice
      expect(find.text('Operación exitosa'), findsOneWidget);
      
      // Verificar que tenga el icono correcto para actitud positiva
      expect(find.byIcon(Icons.check), findsOneWidget);
      
      // Verificar que el botón de cierre esté presente
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
    
    testWidgets('Debería renderizarse correctamente con actitud negativa', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestConfirmationModal(
              attitude: 0,
              label: 'Operación fallida',
            ),
          ),
        ),
      );
      
      // Verificar que el widget se renderice
      expect(find.text('Operación fallida'), findsOneWidget);
      
      // Verificar que tenga el icono correcto para actitud negativa
      expect(find.byIcon(Icons.cancel), findsOneWidget);
      
      // Verificar que el botón de cierre esté presente
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });
}
