import '../../services/API.dart';

class CityBloc {
  final APIService _apiService = APIService();

  Future<Map<String, dynamic>> getCities({
    String? search,
    String order = 'ASC',
    int page = 1,
    int take = 10,
  }) async {
    try {
      final response = await _apiService.get(
        '${_apiService.callCitysEndpoint}?search=${search ?? ''}&order=$order&page=$page&take=$take',
      );
      return response;
    } catch (e) {
      print('Error getting cities: $e');
      rethrow;
    }
  }
}
