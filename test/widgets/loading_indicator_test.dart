import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/widgets/loading_indicator.dart';

void main() {
  group('LoadingIndicator Widget Tests', () {
    testWidgets('should render LoadingIndicator', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: LoadingIndicator()),
      ));
      expect(find.byType(LoadingIndicator), findsOneWidget);
    });
  });
}
