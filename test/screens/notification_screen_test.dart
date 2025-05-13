import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/screens/notification_screen.dart';

void main() {
  group('NotificationScreen Tests', () {
    testWidgets('should render NotificationScreen', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: NotificationScreen(),
      ));
      expect(find.byType(NotificationScreen), findsOneWidget);
    });
  });
}
