import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/screens/edit_profile_screen.dart';

void main() {
  group('EditProfileScreen Tests', () {
    testWidgets('should render EditProfileScreen', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: EditProfileScreen(field: EditProfileField.name, currentValue: 'valor'),
      ));
      expect(find.byType(EditProfileScreen), findsOneWidget);
    });
  });
}
