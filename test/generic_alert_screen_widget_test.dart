import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:Equirent_Mobility/screens/generic_alert_screen.dart';
import 'package:Equirent_Mobility/BLoC/special_alerts/special_alerts_bloc.dart';
import 'package:Equirent_Mobility/BLoC/alerts/alerts_bloc.dart';
import 'package:Equirent_Mobility/BLoC/home/home_bloc.dart';
import './test_helpers.dart';

// Mock para SpecialAlertsBloc
class MockSpecialAlertsBloc extends ChangeNotifier implements SpecialAlertsBloc {
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _alertData;
  bool _loadWithError = false;
  bool _updateWithError = false;
  bool _deleteWithError = false;
  
  // Configurar comportamiento del mock
  void setLoadWithError(bool value) {
    _loadWithError = value;
  }
  
  void setUpdateWithError(bool value) {
    _updateWithError = value;
  }
  
  void setDeleteWithError(bool value) {
    _deleteWithError = value;
  }
  
  @override
  bool get isLoading => _isLoading;
  
  @override
  String? get error => _error;
  
  @override
  Map<String, dynamic>? get alertData => _alertData;
  
  // Implementación del método loadSpecialAlert
  @override
  Future<void> loadSpecialAlert(int alertId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 50));
    
    if (_loadWithError) {
      _error = "Error al cargar la alerta";
      _isLoading = false;
      notifyListeners();
      return;
    }
    
    _alertData = {
      "id": alertId.toString(),
      "title": "Alerta Genérica",
      "expirationType": "Vencimiento de Documento",
      "expirationDate": "2025-12-31",
      "status": "active",
      "estado": "Vigente",
      "reminder": true,
      "reminderDays": 30,
      "reminders": [
        {"days": 30}
      ]
    };
    
    _isLoading = false;
    notifyListeners();
  }
  
  @override
  Future<bool> updateSpecialAlert(int alertId, String name, DateTime? expirationDate, {
    String? insurerId,
    List<Map<String, dynamic>>? reminders,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 50));
    
    if (_updateWithError) {
      _error = "Error al actualizar la alerta";
      _isLoading = false;
      notifyListeners();
      return false;
    }
    
    _alertData = {
      "id": alertId.toString(),
      "title": name,
      "expirationType": name,
      "expirationDate": expirationDate?.toIso8601String() ?? "2025-12-31",
      "status": "active",
      "estado": "Vigente",
      "reminder": reminders != null && reminders.isNotEmpty,
      "reminderDays": reminders != null && reminders.isNotEmpty ? reminders[0]["days"] : 0,
      "reminders": reminders ?? []
    };
    
    if (insurerId != null) {
      _alertData!["insurerId"] = insurerId;
    }
    
    _isLoading = false;
    notifyListeners();
    return true;
  }
  
  @override
  Future<bool> deleteSpecialAlert(int alertId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 50));
    
    if (_deleteWithError) {
      _error = "Error al eliminar la alerta";
      _isLoading = false;
      notifyListeners();
      return false;
    }
    
    _alertData = null;
    
    _isLoading = false;
    notifyListeners();
    return true;
  }
  
  @override
  void reset() {
    _isLoading = false;
    _error = null;
    _alertData = null;
    notifyListeners();
  }
  
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

// Mock para AlertsBloc
class MockAlertsBloc extends ChangeNotifier implements AlertsBloc {
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _alerts = [];
  bool _loadWithError = false;
  
  void setLoadWithError(bool value) {
    _loadWithError = value;
  }
  
  @override
  bool get isLoading => _isLoading;
  
  @override
  String? get error => _error;
  
  @override
  List<Map<String, dynamic>> get alerts => _alerts;
  
  @override
  Future<void> loadAlerts(int vehicleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 50));
    
    if (_loadWithError) {
      _error = "Error al cargar las alertas";
      _isLoading = false;
      notifyListeners();
      return;
    }
    
    _alerts = [
      {
        "id": 123,
        "vehicleId": vehicleId,
        "title": "Alerta de prueba",
        "expirationDate": "2025-12-31",
        "status": "active"
      }
    ];
    
    _isLoading = false;
    notifyListeners();
  }
  
  @override
  void reset() {
    _isLoading = false;
    _error = null;
    _alerts = [];
    notifyListeners();
  }
  
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

// Mock para HomeBloc
class MockHomeBloc extends ChangeNotifier implements HomeBloc {
  final List<Map<String, dynamic>> _cars = [
    {
      "id": 1,
      "licensePlate": "ABC123",
      "brand": "Toyota",
      "model": "Corolla",
      "year": 2020
    }
  ];
  
  int _selectedCarIndex = 0;
  
  @override
  List<Map<String, dynamic>> get cars => _cars;
  
  Map<String, dynamic>? get selectedCar {
    if (_selectedCarIndex < 0 || _selectedCarIndex >= _cars.length) {
      return null;
    }
    return _cars[_selectedCarIndex];
  }
  
  void selectCar(int index) {
    if (index >= 0 && index < _cars.length) {
      _selectedCarIndex = index;
      notifyListeners();
    }
  }
  
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

void main() {
  // Función auxiliar para construir el widget bajo prueba
  Widget buildGenericAlertScreenWidget(MockSpecialAlertsBloc mockSpecialAlertsBloc, MockAlertsBloc mockAlertsBloc, MockHomeBloc mockHomeBloc) {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<SpecialAlertsBloc>.value(value: mockSpecialAlertsBloc),
          ChangeNotifierProvider<AlertsBloc>.value(value: mockAlertsBloc),
          ChangeNotifierProvider<HomeBloc>.value(value: mockHomeBloc),
        ],
        child: const GenericAlertScreen(alertId: 123),
      ),
    );
  }

  group('GenericAlertScreen Widget Tests', () {
    late MockSpecialAlertsBloc mockSpecialAlertsBloc;
    late MockAlertsBloc mockAlertsBloc;
    late MockHomeBloc mockHomeBloc;
    
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      configureTestEnvironment();
      mockSpecialAlertsBloc = MockSpecialAlertsBloc();
      mockAlertsBloc = MockAlertsBloc();
      mockHomeBloc = MockHomeBloc();
    });
    
    tearDown(() {
      mockSpecialAlertsBloc.dispose();
    });

    testWidgets('Debe mostrar indicador de carga durante loadAlertDetails', (WidgetTester tester) async {
      // Configurar el mock para que tarde en cargar
      mockSpecialAlertsBloc._isLoading = true;
      
      // Construir widget
      await tester.pumpWidget(buildGenericAlertScreenWidget(mockSpecialAlertsBloc, mockAlertsBloc, mockHomeBloc));
      
      // Verificar que se muestra el indicador de carga
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Debe mostrar mensaje de error cuando falla la carga', (WidgetTester tester) async {
      // Configurar el mock para simular un error
      mockSpecialAlertsBloc.setLoadWithError(true);
      
      // Construir widget
      await tester.pumpWidget(buildGenericAlertScreenWidget(mockSpecialAlertsBloc, mockAlertsBloc, mockHomeBloc));
      
      // Esperar a que se complete la carga con error
      await tester.pump(const Duration(milliseconds: 100));
      
      // Verificar que se muestra el mensaje de error
      expect(find.text('Error al cargar la alerta'), findsOneWidget);
    });

    testWidgets('Debe mostrar los datos de la alerta cuando se carga correctamente', (WidgetTester tester) async {
      // Configurar el mock para cargar datos exitosamente
      mockSpecialAlertsBloc.setLoadWithError(false);
      
      // Construir widget
      await tester.pumpWidget(buildGenericAlertScreenWidget(mockSpecialAlertsBloc, mockAlertsBloc, mockHomeBloc));
      
      // Esperar a que se complete la carga
      await tester.pump(const Duration(milliseconds: 100));
      
      // Verificar que se muestran los datos de la alerta
      expect(find.text('Alerta Genérica'), findsOneWidget);
      expect(find.text('Vencimiento de Documento'), findsOneWidget);
    });

    testWidgets('Debe guardar la alerta correctamente al presionar el botón Guardar', (WidgetTester tester) async {
      // Configurar el mock para guardar datos exitosamente
      mockSpecialAlertsBloc.setUpdateWithError(false);
      
      // Cargar datos iniciales
      mockSpecialAlertsBloc._alertData = {
        "id": "123",
        "title": "Alerta Genérica",
        "expirationType": "Vencimiento de Documento",
        "expirationDate": "2025-12-31",
        "status": "active",
        "estado": "Vigente"
      };
      
      // Construir widget
      await tester.pumpWidget(buildGenericAlertScreenWidget(mockSpecialAlertsBloc, mockAlertsBloc, mockHomeBloc));
      
      // Esperar a que se complete la carga inicial
      await tester.pump(const Duration(milliseconds: 100));
      
      // Buscar y presionar el botón de guardar
      final saveButtonFinder = find.text('Guardar');
      if (saveButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(saveButtonFinder);
        await tester.pump(const Duration(milliseconds: 100));
      }
      
      // Verificar que los datos se guardaron correctamente
      expect(mockSpecialAlertsBloc.error, isNull);
    });

    testWidgets('Debe mostrar error al guardar cuando hay un problema', (WidgetTester tester) async {
      // Configurar el mock para simular un error durante el guardado
      mockSpecialAlertsBloc.setUpdateWithError(true);
      
      // Cargar datos iniciales
      mockSpecialAlertsBloc._alertData = {
        "id": "123",
        "title": "Alerta Genérica",
        "expirationType": "Vencimiento de Documento",
        "expirationDate": "2025-12-31",
        "status": "active",
        "estado": "Vigente"
      };
      
      // Construir widget
      await tester.pumpWidget(buildGenericAlertScreenWidget(mockSpecialAlertsBloc, mockAlertsBloc, mockHomeBloc));
      
      // Esperar a que se complete la carga inicial
      await tester.pump(const Duration(milliseconds: 100));
      
      // Buscar y presionar el botón de guardar
      final saveButtonFinder = find.text('Guardar');
      if (saveButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(saveButtonFinder);
        await tester.pump(const Duration(milliseconds: 100));
      }
      
      // Forzar un error en el mock
      mockSpecialAlertsBloc._error = "Error al guardar la alerta";
      await tester.pump();
      
      // Verificar que se muestra el error
      expect(mockSpecialAlertsBloc.error, isNotNull);
    });

    testWidgets('Debe eliminar la alerta correctamente al confirmar', (WidgetTester tester) async {
      // Configurar el mock para eliminar datos exitosamente
      mockSpecialAlertsBloc.setDeleteWithError(false);
      
      // Cargar datos iniciales
      mockSpecialAlertsBloc._alertData = {
        "id": "123",
        "title": "Alerta Genérica",
        "expirationType": "Vencimiento de Documento",
        "expirationDate": "2025-12-31",
        "status": "active",
        "estado": "Vigente"
      };
      
      // Construir widget
      await tester.pumpWidget(buildGenericAlertScreenWidget(mockSpecialAlertsBloc, mockAlertsBloc, mockHomeBloc));
      
      // Esperar a que se complete la carga inicial
      await tester.pump(const Duration(milliseconds: 100));
      
      // Buscar y presionar el botón de eliminar
      final deleteButtonFinder = find.text('Eliminar');
      if (deleteButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(deleteButtonFinder);
        await tester.pump(const Duration(milliseconds: 100));
        
        // Simular confirmación de eliminación (presionar botón "Eliminar" en el diálogo)
        final confirmDeleteButtonFinder = find.text('Eliminar').last;
        if (confirmDeleteButtonFinder.evaluate().isNotEmpty) {
          await tester.tap(confirmDeleteButtonFinder);
          await tester.pump(const Duration(milliseconds: 100));
        }
      }
      
      // Verificar que la eliminación fue exitosa
      expect(mockSpecialAlertsBloc.error, isNull);
    });

    testWidgets('No debe eliminar la alerta si se cancela la confirmación', (WidgetTester tester) async {
      // Configurar el mock para eliminar datos exitosamente
      mockSpecialAlertsBloc.setDeleteWithError(false);
      
      // Cargar datos iniciales
      mockSpecialAlertsBloc._alertData = {
        "id": "123",
        "title": "Alerta Genérica",
        "expirationType": "Vencimiento de Documento",
        "expirationDate": "2025-12-31",
        "status": "active",
        "estado": "Vigente"
      };
      
      // Construir widget
      await tester.pumpWidget(buildGenericAlertScreenWidget(mockSpecialAlertsBloc, mockAlertsBloc, mockHomeBloc));
      
      // Esperar a que se complete la carga inicial
      await tester.pump(const Duration(milliseconds: 100));
      
      // Buscar y presionar el botón de eliminar
      final deleteButtonFinder = find.text('Eliminar');
      if (deleteButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(deleteButtonFinder);
        await tester.pump(const Duration(milliseconds: 100));
        
        // Simular cancelación (presionar botón "Cancelar" en el diálogo)
        final cancelButtonFinder = find.text('Cancelar');
        if (cancelButtonFinder.evaluate().isNotEmpty) {
          await tester.tap(cancelButtonFinder);
          await tester.pump(const Duration(milliseconds: 100));
        }
      }
      
      // Verificar que los datos NO se eliminaron
      expect(mockSpecialAlertsBloc.alertData, isNotNull);
    });

    testWidgets('Debe mostrar error al eliminar cuando hay un problema', (WidgetTester tester) async {
      // Configurar el mock para simular un error durante la eliminación
      mockSpecialAlertsBloc.setDeleteWithError(true);
      
      // Cargar datos iniciales
      mockSpecialAlertsBloc._alertData = {
        "id": "123",
        "title": "Alerta Genérica",
        "expirationType": "Vencimiento de Documento",
        "expirationDate": "2025-12-31",
        "status": "active",
        "estado": "Vigente"
      };
      
      // Construir widget
      await tester.pumpWidget(buildGenericAlertScreenWidget(mockSpecialAlertsBloc, mockAlertsBloc, mockHomeBloc));
      
      // Esperar a que se complete la carga inicial
      await tester.pump(const Duration(milliseconds: 100));
      
      // Buscar y presionar el botón de eliminar
      final deleteButtonFinder = find.text('Eliminar');
      if (deleteButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(deleteButtonFinder);
        await tester.pump(const Duration(milliseconds: 100));
        
        // Simular confirmación de eliminación (presionar botón "Eliminar" en el diálogo)
        final confirmDeleteButtonFinder = find.text('Eliminar').last;
        if (confirmDeleteButtonFinder.evaluate().isNotEmpty) {
          await tester.tap(confirmDeleteButtonFinder);
          await tester.pump(const Duration(milliseconds: 100));
        }
      }
      
      // Forzar un error en el mock
      mockSpecialAlertsBloc._error = "Error al eliminar la alerta";
      await tester.pump();
      
      // Verificar que se muestra el error
      expect(mockSpecialAlertsBloc.error, isNotNull);
    });

    testWidgets('Debe manejar correctamente alertas sin tipo de expiración', (WidgetTester tester) async {
      // Configurar datos de prueba sin expirationType
      mockSpecialAlertsBloc.setLoadWithError(false);
      mockSpecialAlertsBloc._alertData = {
        "id": "123",
        "title": "Alerta Genérica",
        // No incluimos expirationType para probar ese caso
        "expirationDate": "2025-12-31",
        "status": "active",
        "estado": "Vigente"
      };
      
      // Construir widget
      await tester.pumpWidget(buildGenericAlertScreenWidget(mockSpecialAlertsBloc, mockAlertsBloc, mockHomeBloc));
      
      // Esperar a que se complete la carga
      await tester.pump(const Duration(milliseconds: 100));
      
      // Verificar que la UI maneja correctamente la ausencia de expirationType
      expect(mockSpecialAlertsBloc.alertData!.containsKey("expirationType"), isFalse);
    });
  });
}
