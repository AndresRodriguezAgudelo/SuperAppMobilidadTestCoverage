import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/screens/extintor_screen.dart';

void main() {
  group('ExtintorScreen Tests', () {
    testWidgets('should render ExtintorScreen', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ExtintorScreen(alertId: 1),
      ));
      expect(find.byType(ExtintorScreen), findsOneWidget);
    });
  });
}
