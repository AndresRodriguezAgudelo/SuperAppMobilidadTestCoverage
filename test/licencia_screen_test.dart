import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/screens/licencia_screen.dart';

void main() {
  group('LicenciaScreen Tests', () {
    testWidgets('should render LicenciaScreen', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: LicenciaScreen(),
      ));
      expect(find.byType(LicenciaScreen), findsOneWidget);
    });
  });
}
