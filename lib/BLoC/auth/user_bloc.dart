import '../../services/API.dart';

class UserBloc {
  final APIService _apiService = APIService();

  Future<Map<String, dynamic>> createUser({
    required String email,
    required String name,
    required bool accepted,
    required int cityId,
    required String phone,
  }) async {
    try {
      final body = {
        'email': email,
        'name': name,
        'accepted': accepted,
        'cityId': cityId,
        'phone': phone,
      };

      print('🚀 Creating user with body:');
      print('📧 email: $email');
      print('👤 name: $name');
      print('✅ accepted: $accepted');
      print('🏙️ cityId: $cityId');
      print('📱 phone: $phone');
      print('📦 Full body: $body');

      final response = await _apiService.post(
        _apiService.createUserEndpoint,
        body: body,
      );

      print('✨ User creation response: $response');
      return response;
    } catch (e) {
      print('❌ Error creating user: $e');
      rethrow;
    }
  }
}
