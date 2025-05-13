import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/screens/multas_screen.dart';

void main() {
  group('MultasScreen Tests', () {
    testWidgets('should render MultasScreen', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: MultasScreen(),
      ));
      expect(find.byType(MultasScreen), findsOneWidget);
    });
  });
}
