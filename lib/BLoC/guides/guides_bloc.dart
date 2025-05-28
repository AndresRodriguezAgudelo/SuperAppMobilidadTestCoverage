import 'package:flutter/foundation.dart';
import 'dart:math' as math;
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
  final String date;

  GuideItem({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.keyMain,
    required this.keySecondary,
    required this.keyTertiaryVideo,
    required this.description,
    required this.date,
  });

  factory GuideItem.fromJson(Map<String, dynamic> json) {
    // Manejar todos los posibles campos nulos
    
    // Manejar id
    final id = json['id'] ?? 0;
    
    // Manejar name
    final name = json['name'] != null ? json['name'] as String : '';
    
    // Manejar categoryId
    final categoryId = json['categoryId'] ?? 0;
    
    // Manejar keyMain
    final keyMain = json['keyMain'] != null ? json['keyMain'] as String : '';
    
    // Manejar keySecondary
    final keySecondary = json['keySecondary'] != null ? json['keySecondary'] as String : '';
    
    // Manejar keyTertiaryVideo
    final keyTertiaryVideo = json['keyTertiaryVideo'] != null ? json['keyTertiaryVideo'] as String : '';
    
    // Manejar description
    final description = json['description'] != null ? json['description'] as String : '';
    
    // Manejar date
    String dateValue = '';
    if (json['date'] != null) {
      dateValue = json['date'] as String;
    } else {
      // Usar fecha actual formateada si no hay date
      final now = DateTime.now();
      dateValue = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    }
    
    // Imprimir información de depuración
    print('\n🔍 GUIDE ITEM FROM JSON:');
    print('ID: $id');
    print('Name: $name');
    print('CategoryID: $categoryId');
    print('KeyMain: $keyMain');
    print('KeySecondary: $keySecondary');
    print('KeyTertiaryVideo: $keyTertiaryVideo');
    print('Description: ${description.substring(0, description.length > 20 ? 20 : description.length)}...');
    print('Date: $dateValue');
    
    return GuideItem(
      id: id,
      name: name,
      categoryId: categoryId,
      keyMain: keyMain,
      keySecondary: keySecondary,
      keyTertiaryVideo: keyTertiaryVideo,
      description: description,
      date: dateValue,
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
      print('🔑 Token: ${_authContext.token?.substring(0, math.min(10, _authContext.token?.length ?? 0))}...');
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

      print('\n✅ RESPUESTA DEL API:');
      print('Tipo de respuesta: ${response.runtimeType}');
      print('Claves en la respuesta: ${response.keys.join(', ')}');

      // Verificar si la respuesta tiene la estructura esperada
      if (response['categories'] != null) {
        final categoriesList = response['categories'];
        print('Tipo de categories: ${categoriesList.runtimeType}');
        
        if (categoriesList is List) {
          try {
            _categories = categoriesList
                .map((category) => GuideCategory.fromJson(category))
                .toList();
            
            print('\n📚 CATEGORÍAS CARGADAS: ${_categories.length}');
            for (var category in _categories) {
              print('📑 ${category.categoryName}: ${category.items.length} items');
              if (category.items.isNotEmpty) {
                final firstItem = category.items.first;
                print('   - Primer item: ${firstItem.name}');
                print('   - Video key: ${firstItem.keyTertiaryVideo}');
              }
            }
          } catch (parseError) {
            print('\n❌ ERROR PARSEANDO CATEGORÍAS:');
            print('📱 Error: $parseError');
            print('📃 Stack trace: ${parseError is Error ? parseError.stackTrace : ''}');
            
            // Intentar imprimir la primera categoría para depuración
            if (categoriesList.isNotEmpty) {
              print('\n🔍 PRIMERA CATEGORÍA (RAW):');
              print(categoriesList.first);
            }
            
            _error = 'Error al procesar las categorías: $parseError';
            _categories = [];
          }
        } else {
          print('⚠️ El campo categories no es una lista: $categoriesList');
          _error = 'El formato de las categorías no es válido';
          _categories = [];
        }
      } else {
        print('⚠️ No se encontraron categorías en la respuesta');
        _categories = [];
      }

    } catch (e) {
      print('\n❌ ERROR OBTENIENDO GUÍAS');
      print('📱 Error: $e');
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
