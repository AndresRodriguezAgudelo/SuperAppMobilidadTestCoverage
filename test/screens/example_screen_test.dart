import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/screens/example_screen.dart';

void main() {
  group('ExampleScreen Tests', () {
    testWidgets('should render ExampleScreen', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: ExampleScreen(),
      ));
      expect(find.byType(ExampleScreen), findsOneWidget);
      // Puedes agregar asserts adicionales para widgets clave del ExampleScreen
    });
  });
}
