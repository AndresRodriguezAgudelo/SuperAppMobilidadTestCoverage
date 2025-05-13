import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/screens/RTM_screen.dart';

void main() {
  group('RTMScreen Tests', () {
    testWidgets('should render RTMScreen', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: RTMScreen(),
      ));
      expect(find.byType(RTMScreen), findsOneWidget);
    });
  });
}
