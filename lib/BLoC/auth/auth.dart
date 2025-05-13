import '../../services/API.dart';
import '../../services/notification_service.dart';
import 'auth_context.dart';
import '../../services/session_manager.dart';

class AuthBloc {
  final APIService _apiService = APIService();
  final AuthContext _authContext = AuthContext();

  Future<Map<String, dynamic>> callOTP(String phone) async {
    try {
      print('\n📲 GENERANDO CÓDIGO OTP');
      print('📱 Teléfono: $phone');

      // Primer intento con type: "login"
      try {
        print('\n🔓 Intentando LOGIN');
        print('📡 Enviando petición a: ${_apiService.callOTPEndpoint}');
        print('📦 Body: {"type": "login", "phone": "$phone"}');

        final response = await _apiService.post(
          _apiService.callOTPEndpoint,
          body: {
            "type": "login",
            "phone": phone,
          },
        );
        print('✅ Respuesta de login: $response');

        final result = {
          'type': 'login',
          'user': response['user'],
          ...response
        };
        print('📄 Resultado final: $result');
        return result;

      } catch (e) {
        // Si la respuesta contiene "Usuario no encontrado", intentamos con register
        if (e is APIException && 
            e.message.contains('Usuario no encontrado')) {
          print('\n🎁 Usuario nuevo, intentando REGISTER');
          print('📡 Enviando petición a: ${_apiService.callOTPEndpoint}');
          print('📦 Body: {"type": "register", "phone": "$phone"}');

          final response = await _apiService.post(
            _apiService.callOTPEndpoint,
            body: {
              "type": "register",
              "phone": phone,
            },
          );
          print('✅ Respuesta de register: $response');

          final result = {
            'type': 'register',
            ...response
          };
          print('📄 Resultado final: $result');
          return result;
        }

        print('\n❌ ERROR EN GENERACIÓN OTP');
        print('📡 Detalles: $e');
        rethrow;
      }
    } catch (e) {
      print('\n❌ ERROR GENERAL');
      print('📡 Detalles: $e');
      rethrow;
    }
  }
  

  Future<Map<String, dynamic>> validateOTP(String otp, String phone, {bool isNewUser = false}) async {
    try {
      print('\n🔑 INICIANDO VALIDACIÓN OTP');
      print('📱 Teléfono: $phone');
      print('🔒 Código OTP: $otp');
      
      // 1. Validar OTP
      print('\n📡 Enviando petición a: ${_apiService.validateOTPEndpoint}');
      print('📦 Body de validación: {"otp": "$otp"}');
      
      final validationResponse = await _apiService.post(
        _apiService.validateOTPEndpoint,
        body: {
          "otp": otp,
        },
      );
      print('✅ Respuesta de validación: $validationResponse');

      // Si es un usuario nuevo, no intentamos hacer login
      if (isNewUser) {
        print('\n🎁 USUARIO NUEVO - Retornando validación exitosa');
        return validationResponse;
      }

      // 2. Si es usuario existente, hacer login con el OTP validado
      print('\n🔓 INICIANDO LOGIN');
      print('📡 Enviando petición a: ${_apiService.loginEndpoint}');
      print('📦 Body de login: {"phone": "$phone", "otp": "$otp"}');
      
      final loginResponse = await _apiService.post(
        _apiService.loginEndpoint,
        body: {
          "phone": phone,
          "otp": otp,
        },
      );
      
      print('✅ Respuesta de login: $loginResponse');

      // 3. Guardar datos del usuario
      if (loginResponse['user'] != null && loginResponse['accessToken'] != null) {
        print('\n💾 GUARDANDO DATOS DE USUARIO');
        final user = loginResponse['user'];
        final token = loginResponse['accessToken'];

        _authContext.setUserData(
          token: token,
          name: user['name'],
          phone: user['phone'].toString(),
          photo: user['photo'],
          userId: user['id'],
        );
        
        // Persistir sesión por 2 días
        final expiry = DateTime.now().add(const Duration(days: 2)).millisecondsSinceEpoch;
        print('AUTH_BLOC: Guardando sesión en SharedPreferences con expiry: $expiry');
        await SessionManager.saveSession(
          token: token,
          expiry: expiry,
          name: user['name'],
          phone: user['phone'].toString(),
          photo: user['photo'],
          userId: user['id'],
        );
        
        print('\n🆔 ID DE USUARIO GUARDADO: ${user["id"]}');
        
        // 4. Registrar el token del dispositivo en el backend
        print('\n📱 REGISTRANDO TOKEN DE DISPOSITIVO EN BACKEND');
        try {
          final notificationService = NotificationService();
          final result = await notificationService.registerDeviceToken();
          if (result) {
            print('✅ Token de dispositivo registrado exitosamente');
          } else {
            print('⚠️ No se pudo registrar el token de dispositivo');
          }
        } catch (e) {
          print('❌ Error al registrar token de dispositivo: $e');
        }
      } else {
        print('⚠️ No se encontraron datos de usuario o token en la respuesta');
      }
      
      return loginResponse;
    } catch (e) {
      print('\n❌ ERROR EN AUTENTICACIÓN');
      print('📡 Detalles: $e');
      rethrow;
    }
  }
}
