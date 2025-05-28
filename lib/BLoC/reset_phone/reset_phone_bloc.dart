import '../../services/API.dart';
import '../auth/auth.dart';
import '../auth/auth_context.dart';

class ResetPhoneBloc {
  final APIService _apiService = APIService();
  final AuthBloc _authBloc = AuthBloc();
  final AuthContext _authContext = AuthContext();
  
  String? _error;
  bool _isLoading = false;
  int? _userId;
  
  // Getters
  String? get error => _error;
  bool get isLoading => _isLoading;
  int? get userId => _userId;
  
  // Método para solicitar código de recuperación por correo
  Future<bool> requestRecoveryCode(String email) async {
    _isLoading = true;
    _error = null;
    
    try {
      print('\n📧 SOLICITANDO CÓDIGO DE RECUPERACIÓN');
      print('📧 Email: $email');
      
      final response = await _apiService.post(
        '/user/recovery/account',
        body: {
          "email": email,
        },
      );
      
      print('✅ Respuesta de recuperación: $response');
      return true;
    } catch (e) {
      print('❌ Error al solicitar código de recuperación: $e');
      _error = e is APIException ? e.message : 'Error al solicitar código de recuperación';
      return false;
    } finally {
      _isLoading = false;
    }
  }
  
  // Método para validar el código OTP de recuperación
  Future<bool> validateResetOTP(String otp, {String? email}) async {
    _isLoading = true;
    _error = null;
    
    try {
      print('\n🔑 VALIDANDO CÓDIGO OTP PARA RECUPERACIÓN');
      print('🔑 OTP: $otp');
      print('📧 Email: $email');
      
      // Crear el body con OTP y email
      final Map<String, dynamic> body = {
        "otp": otp,
      };
      
      // Añadir email si está disponible
      if (email != null && email.isNotEmpty) {
        body["email"] = email;
      }
      
      print('\n📦 CUERPO DE LA PETICIÓN ENVIADO:');
      print(body);
      
      final response = await _apiService.post(
        '/otp/validate/reset',
        body: body,
      );
      
      print('\n✅ RESPUESTA COMPLETA DE VALIDACIÓN:');
      print(response);
      print('\n🔍 TIPO DE RESPUESTA: ${response.runtimeType}');
      print('\n🔍 CONTENIDO DE RESPUESTA JSON: ${response.toString()}');
      
      // Guardar el userId para usarlo en el siguiente paso
      _userId = response['userId'];
      
      return response['validated'] == true;
    } catch (e) {
      print('❌ Error al validar código OTP: $e');
      _error = e is APIException ? e.message : 'Error al validar código';
      return false;
    } finally {
      _isLoading = false;
    }
  }
  
  // Método para actualizar el número de teléfono
  Future<bool> updatePhoneNumber(String phone) async {
    if (_userId == null) {
      _error = 'ID de usuario no disponible';
      return false;
    }
    
    _isLoading = true;
    _error = null;
    
    try {
      print('\n📱 ACTUALIZANDO NÚMERO DE TELÉFONO');
      print('📱 Nuevo teléfono: $phone');
      print('🆔 ID de usuario: $_userId');
      
      final endpoint = _apiService.updateUserProfileEndpoint(_userId!);
      
      final response = await _apiService.patch(
        endpoint,
        body: {
          "phone": phone,
        },
      );
      
      print('✅ Respuesta de actualización: $response');
      return true;
    } catch (e) {
      print('❌ Error al actualizar número de teléfono: $e');
      _error = e is APIException ? e.message : 'Error al actualizar número de teléfono';
      return false;
    } finally {
      _isLoading = false;
    }
  }
  
  // Método para solicitar OTP de login después de actualizar el teléfono
  Future<Map<String, dynamic>> requestLoginOTP(String phone) async {
    try {
      print('📱 SOLICITANDO OTP DE LOGIN');
      print('📱 Teléfono: $phone');
      print('📤 Petición enviada al endpoint: solicitud de OTP para login');
      
      final result = await _authBloc.callOTP(phone);
      print('✅ Respuesta de solicitud OTP: $result');
      return result;
    } catch (e) {
      print('❌ Error al solicitar código de login: $e');
      _error = e is APIException ? e.message : 'Error al solicitar código de login';
      rethrow;
    }
  }
  
  // Método para validar OTP de login y completar el proceso
  Future<bool> validateLoginOTP(String otp, String phone) async {
    try {
      print('🔑 VALIDANDO OTP DE LOGIN');
      print('🔑 OTP: $otp');
      print('📱 Teléfono: $phone');
      print('📤 Petición enviada al endpoint: validación de OTP para login');
      
      final response = await _authBloc.validateOTP(otp, phone);
      print('✅ Respuesta de validación: $response');
      
      // Guardar los datos de sesión
      if (response['accessToken'] != null && response['user'] != null) {
        final userData = response['user'];
        _authContext.setUserData(
          token: response['accessToken'],
          name: userData['name'],
          phone: userData['phone'].toString(),
          photo: userData['photo'],
          userId: userData['id'],
        );
        print('🔑 Sesión iniciada correctamente para el usuario: ${userData['name']}');
        return true;
      }
      print('❌ Error: Respuesta de validación no contiene token o datos de usuario');
      return false;
    } catch (e) {
      print('❌ Error al validar código de login: $e');
      _error = e is APIException ? e.message : 'Error al validar código de login';
      return false;
    }
  }
  
  // Método para limpiar el estado
  void reset() {
    _error = null;
    _isLoading = false;
    _userId = null;
  }
}
