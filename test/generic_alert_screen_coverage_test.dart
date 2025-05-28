import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:Equirent_Mobility/screens/generic_alert_screen.dart';
import 'package:Equirent_Mobility/BLoC/special_alerts/special_alerts_bloc.dart';
import 'package:Equirent_Mobility/BLoC/alerts/alerts_bloc.dart';
import 'package:Equirent_Mobility/BLoC/home/home_bloc.dart';
// Importación eliminada por no ser utilizada
import './test_helpers.dart';

// Mock para SpecialAlertsBloc con implementación más completa
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
  
  // Establecer datos directamente para pruebas
  void setAlertData(Map<String, dynamic> data) {
    _alertData = data;
    notifyListeners();
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
    print("\n🔴🔴🔴 INICIANDO CARGA DE ALERTA ESPECIAL ID: $alertId 🔴🔴🔴");
    _isLoading = true;
    _error = null;
    _alertData = null;
    notifyListeners();
    
    // Simulamos una carga con posible error
    await Future.delayed(const Duration(milliseconds: 50));
    
    if (_loadWithError) {
      _error = "Error al cargar la alerta";
      _isLoading = false;
      print("\n❌ ERROR CARGANDO ALERTA ESPECIAL");
      print("📡 Error: $_error");
      print("\n🟢 CARGA COMPLETADA - alertData: No presente");
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
    print("\n🟢 CARGA COMPLETADA - alertData: Presente");
    print("📢 NOTIFICANDO A LOS LISTENERS CON NUEVOS DATOS");
    notifyListeners();
  }
  
  @override
  Future<bool> updateSpecialAlert(int alertId, String name, DateTime? expirationDate, {
    String? insurerId,
    List<Map<String, dynamic>>? reminders,
  }) async {
    print("\n💾 ACTUALIZANDO ALERTA ESPECIAL ID: $alertId");
    print("Nombre: $name");
    print("Fecha: ${expirationDate?.toIso8601String()}");
    print("Recordatorios: $reminders");
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    // Simulamos una actualización con posible error
    await Future.delayed(const Duration(milliseconds: 50));
    
    if (_updateWithError) {
      _error = "Error al actualizar la alerta";
      _isLoading = false;
      print("\n❌ ERROR ACTUALIZANDO ALERTA ESPECIAL");
      print("📡 Error: $_error");
      notifyListeners();
      return false;
    }
    
    // Actualizamos los datos locales
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
    
    // Añadir insurerId si está presente
    if (insurerId != null) {
      _alertData!["insurerId"] = insurerId;
    }
    
    _isLoading = false;
    print("\n🟢 ACTUALIZACIÓN COMPLETADA - alertData actualizado");
    print("📢 NOTIFICANDO A LOS LISTENERS CON DATOS ACTUALIZADOS");
    notifyListeners();
    return true;
  }
  
  @override
  Future<bool> deleteSpecialAlert(int alertId) async {
    print("\n🚮 ELIMINANDO ALERTA ESPECIAL ID: $alertId");
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    // Simulamos una eliminación con posible error
    await Future.delayed(const Duration(milliseconds: 50));
    
    if (_deleteWithError) {
      _error = "Error al eliminar la alerta";
      _isLoading = false;
      print("\n❌ ERROR ELIMINANDO ALERTA ESPECIAL");
      print("📡 Error: $_error");
      notifyListeners();
      return false;
    }
    
    // Limpiamos los datos locales
    _alertData = null;
    
    _isLoading = false;
    print("\n🟢 ELIMINACIÓN COMPLETADA - alertData eliminado");
    print("📢 NOTIFICANDO A LOS LISTENERS");
    notifyListeners();
    return true;
  }
  
  @override
  void reset() {
    print("\n🔄 REINICIANDO ESTADO DE SPECIALALERTSBLOC");
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
  
  @override
  Map<String, dynamic>? getSelectedVehicle() {
    if (_selectedCarIndex < 0 || _selectedCarIndex >= _cars.length) {
      return null;
    }
    final selectedCar = _cars[_selectedCarIndex];
    print("\n🚗 HOME_BLOC: Vehículo seleccionado: ${selectedCar["licensePlate"]}");
    return selectedCar;
  }
  
  void selectCar(int index) {
    if (index >= 0 && index < _cars.length) {
      _selectedCarIndex = index;
      print("\n🚗 HOME_BLOC: Vehículo seleccionado cambiado a: ${_cars[_selectedCarIndex]["licensePlate"]}");
      notifyListeners();
    }
  }
  
  @override
  dynamic noSuchMethod(Invocation invocation) {
    print("Método no implementado en HomeBloc: ${invocation.memberName}");
    return super.noSuchMethod(invocation);
  }
}

// Mock para ConfirmationModal
class MockNavigatorObserver extends NavigatorObserver {
  List<Route<dynamic>> pushedRoutes = [];
  List<Route<dynamic>> poppedRoutes = [];
  
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
    super.didPush(route, previousRoute);
  }
  
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    poppedRoutes.add(route);
    super.didPop(route, previousRoute);
  }
}

void main() {
  // Función auxiliar para construir el widget bajo prueba
  Widget buildGenericAlertScreenWidget({
    required MockSpecialAlertsBloc mockSpecialAlertsBloc,
    required MockAlertsBloc mockAlertsBloc,
    required MockHomeBloc mockHomeBloc,
    required int alertId,
    List<NavigatorObserver>? navigatorObservers,
  }) {
    return MaterialApp(
      navigatorObservers: navigatorObservers ?? [],
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<SpecialAlertsBloc>.value(value: mockSpecialAlertsBloc),
          ChangeNotifierProvider<AlertsBloc>.value(value: mockAlertsBloc),
          ChangeNotifierProvider<HomeBloc>.value(value: mockHomeBloc),
        ],
        child: GenericAlertScreen(alertId: alertId),
      ),
    );
  }

  group('GenericAlertScreen Coverage Tests', () {
    late MockSpecialAlertsBloc mockSpecialAlertsBloc;
    late MockAlertsBloc mockAlertsBloc;
    late MockHomeBloc mockHomeBloc;
    late MockNavigatorObserver mockNavigatorObserver;
    
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      configureTestEnvironment();
      mockSpecialAlertsBloc = MockSpecialAlertsBloc();
      mockAlertsBloc = MockAlertsBloc();
      mockHomeBloc = MockHomeBloc();
      mockNavigatorObserver = MockNavigatorObserver();
    });
    
    tearDown(() {
      mockSpecialAlertsBloc.dispose();
    });

    // Test para el método _loadAlertDetails con datos completos
    testWidgets('_loadAlertDetails carga datos completos correctamente', (WidgetTester tester) async {
      // Configurar el mock para cargar datos exitosamente
      mockSpecialAlertsBloc.setLoadWithError(false);
      
      // Construir widget
      await tester.pumpWidget(buildGenericAlertScreenWidget(
        mockSpecialAlertsBloc: mockSpecialAlertsBloc,
        mockAlertsBloc: mockAlertsBloc,
        mockHomeBloc: mockHomeBloc,
        alertId: 123,
      ));
      
      // Esperar a que se complete la carga
      await tester.pump(const Duration(milliseconds: 100));
      
      // Verificar que los datos se cargaron correctamente
      expect(mockSpecialAlertsBloc.isLoading, isFalse);
      expect(mockSpecialAlertsBloc.alertData, isNotNull);
      expect(mockSpecialAlertsBloc.error, isNull);
      
      // Verificar que se muestra el nombre de la alerta
      expect(find.text('Alerta Genérica'), findsOneWidget);
    });

    // Test para el método _loadAlertDetails con error
    testWidgets('_loadAlertDetails maneja errores correctamente', (WidgetTester tester) async {
      // Configurar el mock para simular un error durante la carga
      mockSpecialAlertsBloc.setLoadWithError(true);
      
      // Construir widget
      await tester.pumpWidget(buildGenericAlertScreenWidget(
        mockSpecialAlertsBloc: mockSpecialAlertsBloc,
        mockAlertsBloc: mockAlertsBloc,
        mockHomeBloc: mockHomeBloc,
        alertId: 123,
      ));
      
      // Esperar a que se complete la carga con error
      await tester.pump(const Duration(milliseconds: 100));
      
      // Verificar que el error se maneja correctamente
      expect(mockSpecialAlertsBloc.isLoading, isFalse);
      expect(mockSpecialAlertsBloc.error, isNotNull);
      expect(mockSpecialAlertsBloc.alertData, isNull);
    });

    // Test para el método _saveAlert con éxito
    testWidgets('_saveAlert guarda la alerta correctamente', (WidgetTester tester) async {
      // Configurar el mock para guardar datos exitosamente
      mockSpecialAlertsBloc.setUpdateWithError(false);
      
      // Establecer datos iniciales
      mockSpecialAlertsBloc.setAlertData({
        "id": "123",
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
      });
      
      // Construir widget
      await tester.pumpWidget(buildGenericAlertScreenWidget(
        mockSpecialAlertsBloc: mockSpecialAlertsBloc,
        mockAlertsBloc: mockAlertsBloc,
        mockHomeBloc: mockHomeBloc,
        alertId: 123,
        navigatorObservers: [mockNavigatorObserver],
      ));
      
      // Esperar a que se complete la carga inicial
      await tester.pump(const Duration(milliseconds: 100));
      
      // Encontrar y presionar el botón de guardar
      final saveButton = find.text('Guardar');
      expect(saveButton, findsOneWidget);
      await tester.tap(saveButton);
      await tester.pump(const Duration(milliseconds: 100));
      
      // Verificar que se guardó correctamente
      expect(mockSpecialAlertsBloc.error, isNull);
    });

    // Test para el método _saveAlert con error
    testWidgets('_saveAlert maneja errores correctamente', (WidgetTester tester) async {
      // Configurar el mock para simular un error durante el guardado
      mockSpecialAlertsBloc.setUpdateWithError(true);
      
      // Establecer datos iniciales
      mockSpecialAlertsBloc.setAlertData({
        "id": "123",
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
      });
      
      // Construir widget
      await tester.pumpWidget(buildGenericAlertScreenWidget(
        mockSpecialAlertsBloc: mockSpecialAlertsBloc,
        mockAlertsBloc: mockAlertsBloc,
        mockHomeBloc: mockHomeBloc,
        alertId: 123,
      ));
      
      // Esperar a que se complete la carga inicial
      await tester.pump(const Duration(milliseconds: 100));
      
      // Encontrar y presionar el botón de guardar
      final saveButton = find.text('Guardar');
      expect(saveButton, findsOneWidget);
      await tester.tap(saveButton);
      await tester.pump(const Duration(milliseconds: 100));
      
      // Verificar que se manejó el error correctamente
      expect(mockSpecialAlertsBloc.error, isNotNull);
    });

    // Test para el método _saveAlert con nombre predeterminado
    testWidgets('_saveAlert usa nombre predeterminado cuando ambos nombres son vacíos', (WidgetTester tester) async {
      // Configurar el mock para guardar datos exitosamente
      mockSpecialAlertsBloc.setUpdateWithError(false);
      
      // Establecer datos iniciales sin nombre
      mockSpecialAlertsBloc.setAlertData({
        "id": "123",
        "expirationDate": "2025-12-31",
        "status": "active",
        "estado": "Vigente",
        "reminder": true,
        "reminderDays": 30,
        "reminders": [
          {"days": 30}
        ]
      });
      
      // Construir widget
      await tester.pumpWidget(buildGenericAlertScreenWidget(
        mockSpecialAlertsBloc: mockSpecialAlertsBloc,
        mockAlertsBloc: mockAlertsBloc,
        mockHomeBloc: mockHomeBloc,
        alertId: 123,
      ));
      
      // Esperar a que se complete la carga inicial
      await tester.pump(const Duration(milliseconds: 100));
      
      // Encontrar y presionar el botón de guardar
      final saveButton = find.text('Guardar');
      expect(saveButton, findsOneWidget);
      await tester.tap(saveButton);
      await tester.pump(const Duration(milliseconds: 100));
      
      // Verificar que se guardó correctamente con un nombre predeterminado
      expect(mockSpecialAlertsBloc.error, isNull);
    });

    // Test para el método _deleteAlert con confirmación
    testWidgets('_deleteAlert elimina la alerta cuando se confirma', (WidgetTester tester) async {
      // Configurar el mock para eliminar datos exitosamente
      mockSpecialAlertsBloc.setDeleteWithError(false);
      
      // Establecer datos iniciales
      mockSpecialAlertsBloc.setAlertData({
        "id": "123",
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
      });
      
      // Construir widget
      await tester.pumpWidget(buildGenericAlertScreenWidget(
        mockSpecialAlertsBloc: mockSpecialAlertsBloc,
        mockAlertsBloc: mockAlertsBloc,
        mockHomeBloc: mockHomeBloc,
        alertId: 123,
        navigatorObservers: [mockNavigatorObserver],
      ));
      
      // Esperar a que se complete la carga inicial
      await tester.pump(const Duration(milliseconds: 100));
      
      // Encontrar y presionar el botón de eliminar
      final deleteButton = find.text('Eliminar');
      expect(deleteButton, findsOneWidget);
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();
      
      // Confirmar la eliminación
      final confirmDeleteButton = find.text('Eliminar').last;
      expect(confirmDeleteButton, findsOneWidget);
      await tester.tap(confirmDeleteButton);
      await tester.pumpAndSettle();
      
      // Verificar que se eliminó correctamente
      expect(mockSpecialAlertsBloc.error, isNull);
    });

    // Test para el método _deleteAlert con cancelación
    testWidgets('_deleteAlert no elimina la alerta cuando se cancela', (WidgetTester tester) async {
      // Configurar el mock para eliminar datos exitosamente
      mockSpecialAlertsBloc.setDeleteWithError(false);
      
      // Establecer datos iniciales
      mockSpecialAlertsBloc.setAlertData({
        "id": "123",
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
      });
      
      // Construir widget
      await tester.pumpWidget(buildGenericAlertScreenWidget(
        mockSpecialAlertsBloc: mockSpecialAlertsBloc,
        mockAlertsBloc: mockAlertsBloc,
        mockHomeBloc: mockHomeBloc,
        alertId: 123,
        navigatorObservers: [mockNavigatorObserver],
      ));
      
      // Esperar a que se complete la carga inicial
      await tester.pump(const Duration(milliseconds: 100));
      
      // Encontrar y presionar el botón de eliminar
      final deleteButton = find.text('Eliminar');
      expect(deleteButton, findsOneWidget);
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();
      
      // Cancelar la eliminación
      final cancelButton = find.text('Cancelar');
      expect(cancelButton, findsOneWidget);
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();
      
      // Verificar que no se eliminó
      expect(mockSpecialAlertsBloc.alertData, isNotNull);
    });

    // Test para el método _deleteAlert con error
    testWidgets('_deleteAlert maneja errores correctamente', (WidgetTester tester) async {
      // Configurar el mock para simular un error durante la eliminación
      mockSpecialAlertsBloc.setDeleteWithError(true);
      
      // Establecer datos iniciales
      mockSpecialAlertsBloc.setAlertData({
        "id": "123",
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
      });
      
      // Construir widget
      await tester.pumpWidget(buildGenericAlertScreenWidget(
        mockSpecialAlertsBloc: mockSpecialAlertsBloc,
        mockAlertsBloc: mockAlertsBloc,
        mockHomeBloc: mockHomeBloc,
        alertId: 123,
        navigatorObservers: [mockNavigatorObserver],
      ));
      
      // Esperar a que se complete la carga inicial
      await tester.pump(const Duration(milliseconds: 100));
      
      // Encontrar y presionar el botón de eliminar
      final deleteButton = find.text('Eliminar');
      expect(deleteButton, findsOneWidget);
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();
      
      // Confirmar la eliminación
      final confirmDeleteButton = find.text('Eliminar').last;
      expect(confirmDeleteButton, findsOneWidget);
      await tester.tap(confirmDeleteButton);
      await tester.pumpAndSettle();
      
      // Verificar que se manejó el error correctamente
      expect(mockSpecialAlertsBloc.error, isNotNull);
    });

    // Test para verificar la inicialización del widget
    testWidgets('Inicializa correctamente el widget', (WidgetTester tester) async {
      // Configurar el mock para cargar datos exitosamente
      mockSpecialAlertsBloc.setLoadWithError(false);
      
      // Establecer datos iniciales
      mockSpecialAlertsBloc.setAlertData({
        "id": "123",
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
      });
      
      // Construir widget
      await tester.pumpWidget(buildGenericAlertScreenWidget(
        mockSpecialAlertsBloc: mockSpecialAlertsBloc,
        mockAlertsBloc: mockAlertsBloc,
        mockHomeBloc: mockHomeBloc,
        alertId: 123,
      ));
      
      // Esperar a que se complete la carga inicial
      await tester.pump(const Duration(milliseconds: 100));
      
      // Verificar que el widget se inicializa correctamente
      expect(find.byType(GenericAlertScreen), findsOneWidget);
    });

    // Test para verificar la presencia de botones principales
    testWidgets('Muestra botones de guardar y eliminar', (WidgetTester tester) async {
      // Configurar el mock para cargar datos exitosamente
      mockSpecialAlertsBloc.setLoadWithError(false);
      
      // Establecer datos iniciales
      mockSpecialAlertsBloc.setAlertData({
        "id": "123",
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
      });
      
      // Construir widget
      await tester.pumpWidget(buildGenericAlertScreenWidget(
        mockSpecialAlertsBloc: mockSpecialAlertsBloc,
        mockAlertsBloc: mockAlertsBloc,
        mockHomeBloc: mockHomeBloc,
        alertId: 123,
      ));
      
      // Esperar a que se complete la carga inicial
      await tester.pump(const Duration(milliseconds: 100));
      
      // Verificar que se muestran los botones principales
      expect(find.text('Guardar'), findsOneWidget);
      expect(find.text('Eliminar'), findsOneWidget);
    });
  });
}
