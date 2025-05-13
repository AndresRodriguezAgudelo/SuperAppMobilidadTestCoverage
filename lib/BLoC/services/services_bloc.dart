import 'package:flutter/foundation.dart';
import '../../services/API.dart';
import '../auth/auth_context.dart';

class ServicesBloc extends ChangeNotifier {
  final APIService _apiService = APIService();
  final AuthContext _authContext = AuthContext();
  
  List<dynamic> _services = [];
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<dynamic> get services => _services;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> getServices({int page = 1, int take = 10}) async {
    try {
      debugPrint('\n🔄 OBTENIENDO SERVICIOS');
      ///debugPrint('📄 Página: $page, Cantidad: $take');
      
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      //debugPrint('🔑 Token: ${_authContext.token}');
      
      final response = await _apiService.get(
        _apiService.getServicingListEndpoint,
        queryParams: {
          'page': page.toString(),
          'take': take.toString(),
          'order': 'ASC',
        },
        token: _authContext.token,
      );
      
      //debugPrint('✅ Respuesta: $response');
      
      _services = (response['data'] as List).map((service) => {
        'title': service['name'],
        'description': service['description'],
        'url': service['link'],
        'imageKey': service['key'],
      }).toList();
      
      _isLoading = false;
      notifyListeners();
      
      //debugPrint('💾 Servicios almacenados: ${_services.length}');
    } catch (e) {
      debugPrint('\n❌ ERROR OBTENIENDO SERVICIOS');
      ///debugPrint('📡 Error: $e');
      
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void clearServices() {
    ///debugPrint('\n🗑 LIMPIANDO SERVICIOS');
    _services = [];
    _error = null;
    notifyListeners();
    ///debugPrint('✅ Servicios limpiados');
  }
}
