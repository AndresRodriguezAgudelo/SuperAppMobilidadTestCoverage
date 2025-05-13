import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/widgets/modales.dart';

void main() {
  group('CustomDialog Widget Tests', () {
    testWidgets('should render CustomModal with required fields', (WidgetTester tester) async {
      // Build the CustomModal widget
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => CustomModal(
                      icon: Icons.info,
                      title: 'Test Title',
                      content: 'Test Content',
                      buttonText: 'OK',
                      onButtonPressed: () => Navigator.of(context).pop(),
                    ),
                  );
                },
                child: const Text('Open Modal'),
              );
            },
          ),
        ),
      );
      // Tap the button to open the modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Check that the modal content is rendered
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Content'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
      expect(find.byIcon(Icons.info), findsOneWidget);
    });
  });
}
