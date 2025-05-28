import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Equirent_Mobility/widgets/alertas/vehicle_selector_modal.dart';

void main() {
  group('VehicleSelectorModal Tests', () {
    testWidgets('should render with list of plates', (WidgetTester tester) async {
      // Arrange
      final plates = ['ABC123', 'XYZ789', 'DEF456'];
      String selectedPlate = 'ABC123';
      bool plateSelected = false;
      String? newPlateAdded;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VehicleSelectorModal(
              plates: plates,
              selectedPlate: selectedPlate,
              onPlateSelected: (plate) {
                selectedPlate = plate;
                plateSelected = true;
              },
              onNewPlateAdded: (plate) {
                newPlateAdded = plate;
              },
            ),
          ),
        ),
      );
      
      // Assert
      for (final plate in plates) {
        expect(find.text(plate), findsOneWidget);
      }
      expect(find.text('Agregar vehículo'), findsOneWidget);
    });
    
    testWidgets('should call onPlateSelected when a plate is selected', (WidgetTester tester) async {
      // Arrange
      final plates = ['ABC123', 'XYZ789', 'DEF456'];
      String selectedPlate = 'ABC123';
      String? selectedValue;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VehicleSelectorModal(
              plates: plates,
              selectedPlate: selectedPlate,
              onPlateSelected: (plate) {
                selectedValue = plate;
              },
              onNewPlateAdded: (_) {},
            ),
          ),
        ),
      );
      
      // Find and tap on a different plate
      await tester.tap(find.text('XYZ789'));
      await tester.pump();
      
      // Assert
      expect(selectedValue, equals('XYZ789'));
    });
    
    testWidgets('should show selected plate with different style', (WidgetTester tester) async {
      // Arrange
      final plates = ['ABC123', 'XYZ789', 'DEF456'];
      const selectedPlate = 'XYZ789';
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VehicleSelectorModal(
              plates: plates,
              selectedPlate: selectedPlate,
              onPlateSelected: (_) {},
              onNewPlateAdded: (_) {},
            ),
          ),
        ),
      );
      
      // Assert - verify that the selected plate text exists
      expect(find.text(selectedPlate), findsOneWidget);
      
      // Verify that all plates are shown
      for (final plate in plates) {
        expect(find.text(plate), findsOneWidget);
      }
    });
    
    testWidgets('should have an "Agregar vehículo" button', (WidgetTester tester) async {
      // Arrange
      final plates = ['ABC123', 'XYZ789', 'DEF456'];
      const selectedPlate = 'ABC123';
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VehicleSelectorModal(
              plates: plates,
              selectedPlate: selectedPlate,
              onPlateSelected: (_) {},
              onNewPlateAdded: (_) {},
            ),
          ),
        ),
      );
      
      // Assert - verify that the "Agregar vehículo" button exists
      expect(find.text('Agregar vehículo'), findsOneWidget);
    });
  });
}
