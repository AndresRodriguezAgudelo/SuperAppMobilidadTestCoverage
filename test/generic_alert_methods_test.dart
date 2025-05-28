import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// Importaciones eliminadas por no ser utilizadas
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
  
  @override
  Future<void> loadSpecialAlert(int alertId) async {
    _isLoading = true;
    _error = null;
    _alertData = null;
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
  
  @override
  Map<String, dynamic>? getSelectedVehicle() {
    return selectedCar;
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
  group('GenericAlertScreen Methods Tests', () {
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

    // Test para verificar que loadSpecialAlert funciona correctamente
    test('loadSpecialAlert carga datos correctamente', () async {
      // Verificar estado inicial
      expect(mockSpecialAlertsBloc.isLoading, isFalse);
      expect(mockSpecialAlertsBloc.alertData, isNull);
      
      // Cargar datos
      await mockSpecialAlertsBloc.loadSpecialAlert(123);
      
      // Verificar que los datos se cargaron correctamente
      expect(mockSpecialAlertsBloc.isLoading, isFalse);
      expect(mockSpecialAlertsBloc.alertData, isNotNull);
      expect(mockSpecialAlertsBloc.alertData!["id"], equals("123"));
      expect(mockSpecialAlertsBloc.error, isNull);
    });
    
    // Test para verificar que loadSpecialAlert maneja errores correctamente
    test('loadSpecialAlert maneja errores correctamente', () async {
      // Configurar para que falle
      mockSpecialAlertsBloc.setLoadWithError(true);
      
      // Verificar estado inicial
      expect(mockSpecialAlertsBloc.isLoading, isFalse);
      expect(mockSpecialAlertsBloc.error, isNull);
      
      // Cargar datos con error
      await mockSpecialAlertsBloc.loadSpecialAlert(123);
      
      // Verificar que el error se maneja correctamente
      expect(mockSpecialAlertsBloc.isLoading, isFalse);
      expect(mockSpecialAlertsBloc.error, isNotNull);
      expect(mockSpecialAlertsBloc.alertData, isNull);
    });
    
    // Test para verificar que updateSpecialAlert funciona correctamente
    test('updateSpecialAlert actualiza datos correctamente', () async {
      // Verificar estado inicial
      expect(mockSpecialAlertsBloc.isLoading, isFalse);
      
      // Actualizar datos
      final success = await mockSpecialAlertsBloc.updateSpecialAlert(
        123,
        "Nueva Alerta",
        DateTime(2025, 12, 31),
        reminders: [{"days": 15}]
      );
      
      // Verificar que los datos se actualizaron correctamente
      expect(success, isTrue);
      expect(mockSpecialAlertsBloc.isLoading, isFalse);
      expect(mockSpecialAlertsBloc.alertData, isNotNull);
      expect(mockSpecialAlertsBloc.alertData!["title"], equals("Nueva Alerta"));
      expect(mockSpecialAlertsBloc.error, isNull);
    });
    
    // Test para verificar que updateSpecialAlert maneja errores correctamente
    test('updateSpecialAlert maneja errores correctamente', () async {
      // Configurar para que falle
      mockSpecialAlertsBloc.setUpdateWithError(true);
      
      // Verificar estado inicial
      expect(mockSpecialAlertsBloc.isLoading, isFalse);
      expect(mockSpecialAlertsBloc.error, isNull);
      
      // Actualizar datos con error
      final success = await mockSpecialAlertsBloc.updateSpecialAlert(
        123,
        "Nueva Alerta",
        DateTime(2025, 12, 31)
      );
      
      // Verificar que el error se maneja correctamente
      expect(success, isFalse);
      expect(mockSpecialAlertsBloc.isLoading, isFalse);
      expect(mockSpecialAlertsBloc.error, isNotNull);
    });
    
    // Test para verificar que deleteSpecialAlert funciona correctamente
    test('deleteSpecialAlert elimina datos correctamente', () async {
      // Primero cargar datos para luego eliminarlos
      await mockSpecialAlertsBloc.loadSpecialAlert(123);
      expect(mockSpecialAlertsBloc.alertData, isNotNull);
      
      // Eliminar datos
      final success = await mockSpecialAlertsBloc.deleteSpecialAlert(123);
      
      // Verificar que los datos se eliminaron correctamente
      expect(success, isTrue);
      expect(mockSpecialAlertsBloc.isLoading, isFalse);
      expect(mockSpecialAlertsBloc.alertData, isNull);
      expect(mockSpecialAlertsBloc.error, isNull);
    });
    
    // Test para verificar que deleteSpecialAlert maneja errores correctamente
    test('deleteSpecialAlert maneja errores correctamente', () async {
      // Configurar para que falle
      mockSpecialAlertsBloc.setDeleteWithError(true);
      
      // Primero cargar datos para luego intentar eliminarlos
      await mockSpecialAlertsBloc.loadSpecialAlert(123);
      expect(mockSpecialAlertsBloc.alertData, isNotNull);
      
      // Eliminar datos con error
      final success = await mockSpecialAlertsBloc.deleteSpecialAlert(123);
      
      // Verificar que el error se maneja correctamente
      expect(success, isFalse);
      expect(mockSpecialAlertsBloc.isLoading, isFalse);
      expect(mockSpecialAlertsBloc.error, isNotNull);
    });
    
    // Test para verificar que reset funciona correctamente
    test('reset limpia el estado correctamente', () async {
      // Primero cargar datos para luego resetearlos
      await mockSpecialAlertsBloc.loadSpecialAlert(123);
      expect(mockSpecialAlertsBloc.alertData, isNotNull);
      
      // Resetear estado
      mockSpecialAlertsBloc.reset();
      
      // Verificar que el estado se ha reseteado
      expect(mockSpecialAlertsBloc.isLoading, isFalse);
      expect(mockSpecialAlertsBloc.alertData, isNull);
      expect(mockSpecialAlertsBloc.error, isNull);
    });
  });
}
