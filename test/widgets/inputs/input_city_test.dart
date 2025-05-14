import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:Equirent_Mobility/widgets/inputs/input_city.dart';
import 'package:Equirent_Mobility/BLoC/pick_and_plate/pick_and_plate_bloc.dart';
import '../../test_helpers.dart';

class MockPeakPlateBloc extends ChangeNotifier implements PeakPlateBloc {
  Map<String, dynamic>? _selectedCity;
  List<Map<String, dynamic>> _cities = [];
  bool _isLoading = false;
  
  @override
  Map<String, dynamic>? get selectedCity => _selectedCity;
  
  @override
  List<Map<String, dynamic>> get cities => _cities;
  
  @override
  bool get isLoading => _isLoading;
  
  @override
  String? get error => null;
  
  void setCity(Map<String, dynamic> city) {
    _selectedCity = city;
    notifyListeners();
  }
  
  void setCities(List<Map<String, dynamic>> cities) {
    _cities = cities;
    notifyListeners();
  }
  
  @override
  Future<void> loadCities() async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 100));
    
    _cities = [
      {'id': 1, 'cityName': 'Bogotá'},
      {'id': 2, 'cityName': 'Medellín'},
      {'id': 3, 'cityName': 'Cali'}
    ];
    
    _isLoading = false;
    notifyListeners();
    return;
  }
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('InputCity Tests', () {
    late MockPeakPlateBloc mockPeakPlateBloc;
    
    setUp(() {
      configureTestEnvironment();
      mockPeakPlateBloc = MockPeakPlateBloc();
    });
    
    testWidgets('Debe mostrar el texto de placeholder cuando no hay ciudad seleccionada', 
      (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<PeakPlateBloc>.value(
            value: mockPeakPlateBloc,
            child: Scaffold(
              body: InputCity(
                label: 'Ciudad',
                onChanged: (_, __) {},
              ),
            ),
          ),
        ),
      );
      
      // Verificar que se muestra la etiqueta
      expect(find.text('Ciudad'), findsOneWidget);
      
      // Verificar que se muestra el contenedor para seleccionar ciudad
      expect(find.byType(GestureDetector), findsOneWidget);
    });
  });
}
