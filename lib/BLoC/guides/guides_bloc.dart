import 'package:flutter/foundation.dart';
import '../../services/API.dart';
import '../auth/auth_context.dart';

class GuideCategory {
  final String categoryName;
  final List<GuideItem> items;

  GuideCategory({
    required this.categoryName,
    required this.items,
  });

  factory GuideCategory.fromJson(Map<String, dynamic> json) {
    return GuideCategory(
      categoryName: json['categoryName'] as String,
      items: (json['items'] as List)
          .map((item) => GuideItem.fromJson(item))
          .toList(),
    );
  }
}

class GuideItem {
  final int id;
  final String name;
  final int categoryId;
  final String keyMain;
  final String keySecondary;
  final String keyTertiaryVideo;
  final String description;

  GuideItem({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.keyMain,
    required this.keySecondary,
    required this.keyTertiaryVideo,
    required this.description,
  });

  factory GuideItem.fromJson(Map<String, dynamic> json) {
    return GuideItem(
      id: json['id'] as int,
      name: json['name'] as String,
      categoryId: json['categoryId'] as int,
      keyMain: json['keyMain'] as String,
      keySecondary: json['keySecondary'] as String,
      keyTertiaryVideo: json['keyTertiaryVideo'] as String,
      description: json['description'] as String,
    );
  }
}

class GuidesBloc extends ChangeNotifier {
  static final GuidesBloc _instance = GuidesBloc._internal();
  factory GuidesBloc() => _instance;

  GuidesBloc._internal();

  final APIService _apiService = APIService();
  final AuthContext _authContext = AuthContext();
  
  List<GuideCategory> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<GuideCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadGuides() async {
    if (_isLoading) return;

    try {
      print('\n📚 OBTENIENDO GUÍAS');
      print('🔑 Token: ${_authContext.token}');
      print('📍 Endpoint: ${_apiService.getAllGuidesEndpoint}');
      
      _isLoading = true;
      _error = null;
      notifyListeners();

      final queryParams = {
        'page': '1',
        'take': '100',
        'order': 'ASC',
      };

      print('📝 Query params: $queryParams');

      final response = await _apiService.get(
        _apiService.getAllGuidesEndpoint,
        token: _authContext.token,
        queryParams: queryParams,
      );

      print('✅ Respuesta completa: $response');

      if (response['categories'] != null) {
        _categories = (response['categories'] as List)
            .map((category) => GuideCategory.fromJson(category))
            .toList();
        
        print('📚 Categorías cargadas: ${_categories.length}');
        for (var category in _categories) {
          print('📑 ${category.categoryName}: ${category.items.length} items');
        }
      } else {
        print('⚠️ No se encontraron categorías en la respuesta');
        _categories = [];
      }

    } catch (e) {
      print('\n❌ ERROR OBTENIENDO GUÍAS');
      print('📡 Error: $e');
      print('📃 Stack trace: ${e is Error ? e.stackTrace : ''}');
      _error = e.toString();
      _categories = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _categories = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
