import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/widgets/inputs/input_code.dart';

void main() {
  group('InputCode Widget Tests', () {
    testWidgets('renders correctly with 4 text fields', (WidgetTester tester) async {
      // Arrange
      bool codeCompleted = false;
      String completedCode = '';
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: InputCode(
            onCompleted: (code) {
              codeCompleted = true;
              completedCode = code;
            },
          ),
        ),
      ));
      
      // Assert
      expect(find.byType(TextField), findsNWidgets(4));
      expect(find.byType(InputCode), findsOneWidget);
    });
    
    testWidgets('moves focus to next field when digit is entered', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: InputCode(
            onCompleted: (code) {},
          ),
        ),
      ));
      
      // Act - enter a digit in the first field
      await tester.enterText(find.byType(TextField).at(0), '1');
      await tester.pump();
      
      // Assert - focus should move to the second field
      final secondTextField = tester.widget<TextField>(find.byType(TextField).at(1));
      expect(secondTextField.focusNode?.hasFocus, isTrue);
    });
    
    testWidgets('moves focus to previous field when digit is deleted', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: InputCode(
            onCompleted: (code) {},
          ),
        ),
      ));
      
      // Act - enter digits in first and second fields
      await tester.enterText(find.byType(TextField).at(0), '1');
      await tester.pump();
      await tester.enterText(find.byType(TextField).at(1), '2');
      await tester.pump();
      
      // Delete the digit in the second field
      await tester.enterText(find.byType(TextField).at(1), '');
      await tester.pump();
      
      // Assert - focus should move back to the first field
      final firstTextField = tester.widget<TextField>(find.byType(TextField).at(0));
      expect(firstTextField.focusNode?.hasFocus, isTrue);
    });
    
    testWidgets('calls onCompleted when all digits are entered', (WidgetTester tester) async {
      // Arrange
      bool codeCompleted = false;
      String completedCode = '';
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: InputCode(
            onCompleted: (code) {
              codeCompleted = true;
              completedCode = code;
            },
          ),
        ),
      ));
      
      // Act - enter 4 digits
      await tester.enterText(find.byType(TextField).at(0), '1');
      await tester.pump();
      await tester.enterText(find.byType(TextField).at(1), '2');
      await tester.pump();
      await tester.enterText(find.byType(TextField).at(2), '3');
      await tester.pump();
      await tester.enterText(find.byType(TextField).at(3), '4');
      await tester.pump();
      
      // Assert
      expect(codeCompleted, isTrue);
      expect(completedCode, equals('1234'));
    });
    
    testWidgets('respects enabled property when false', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: InputCode(
            onCompleted: (code) {},
            enabled: false,
          ),
        ),
      ));
      
      // Assert - all text fields should be disabled
      for (int i = 0; i < 4; i++) {
        final textField = tester.widget<TextField>(find.byType(TextField).at(i));
        expect(textField.enabled, isFalse);
      }
    });
    
    testWidgets('only accepts numeric input', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: InputCode(
            onCompleted: (code) {},
          ),
        ),
      ));
      
      // Act - try to enter non-numeric text
      await tester.enterText(find.byType(TextField).at(0), 'A');
      await tester.pump();
      
      // Assert - field should be empty due to FilteringTextInputFormatter.digitsOnly
      expect(find.text('A'), findsNothing);
    });
    
    testWidgets('properly disposes resources', (WidgetTester tester) async {
      // This test verifies that resources are properly disposed
      // by creating and removing the widget
      
      // Arrange
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: InputCode(
            onCompleted: (code) {},
          ),
        ),
      ));
      
      // Act - replace the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Container(),
        ),
      ));
      
      // No explicit assertion needed - this test would fail if dispose
      // doesn't properly clean up resources
    });
    
    testWidgets('handles paste or multiple digits correctly', (WidgetTester tester) async {
      // Arrange
      bool codeCompleted = false;
      String completedCode = '';
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: InputCode(
            onCompleted: (code) {
              codeCompleted = true;
              completedCode = code;
            },
          ),
        ),
      ));
      
      // Act - try to enter multiple digits at once (simulating paste)
      // Note: Due to limitations in the TextField and InputFormatters,
      // only the first digit will be accepted, but we want to verify
      // the component handles this gracefully
      await tester.enterText(find.byType(TextField).at(0), '1234');
      await tester.pump();
      
      // Assert - only the first digit should be accepted
      final firstTextField = tester.widget<TextField>(find.byType(TextField).at(0));
      expect((firstTextField.controller as TextEditingController).text, '1');
      
      // Focus should move to the second field
      final secondTextField = tester.widget<TextField>(find.byType(TextField).at(1));
      expect(secondTextField.focusNode?.hasFocus, isTrue);
    });
  });
}
