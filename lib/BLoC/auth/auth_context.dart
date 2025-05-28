import 'package:flutter/material.dart';
import '../../screens/notification_screen.dart';
import '../home/home_bloc.dart';
import '../alerts/alerts_bloc.dart';
import '../guides/guides_bloc.dart';
import '../multas/multas_bloc.dart';
import '../profile/profile_bloc.dart';
import '../pick_and_plate/pick_and_plate_bloc.dart'; // Contiene PeakPlateBloc
import '../historial_vehicular/historial_vehicular_bloc.dart';
import '../special_alerts/special_alerts_bloc.dart';

class AuthContext extends ChangeNotifier {
  // Singleton instance
  static final AuthContext _instance = AuthContext._internal();
  factory AuthContext() => _instance;
  AuthContext._internal();

  String? _token;
  String? _name;
  String? _phone;
  String? _photo;
  int? _userId;

  // Getters
  String? get token => _token;
  String? get name => _name;
  String? get phone => _phone;
  String? get photo => _photo;
  int? get userId => _userId;
  
  void setUserData({
    required String token,
    required String name,
    required String phone,
    String? photo,
    int? userId,
  }) {
    debugPrint('\n💾 ACTUALIZANDO DATOS DE USUARIO');
    debugPrint('🔑 Token: $token');
    debugPrint('👤 Nombre: $name');
    debugPrint('📱 Teléfono: $phone');
    debugPrint('🖼 Foto: $photo');
    
    _token = token;
    _name = name;
    _phone = phone;
    _photo = photo;
    _userId = userId;
    
    notifyListeners();
    print('✅ Datos actualizados en context');
  }
  
  // Método para actualizar solo la foto de perfil
  void updatePhoto(String? photoUrl) {
    print('\n💼 ACTUALIZANDO FOTO DE PERFIL EN AUTH CONTEXT');
    print('💼 URL de la foto: $photoUrl');
    
    if (photoUrl != null && photoUrl.isNotEmpty) {
      // Agregar un parámetro de tiempo para forzar la recarga de la imagen
      // y evitar problemas de caché
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      // Verificar si la URL ya tiene parámetros
      if (photoUrl.contains('?')) {
        _photo = '$photoUrl&t=$timestamp';
      } else {
        _photo = '$photoUrl?t=$timestamp';
      }
      
      print('💼 URL modificada con timestamp: $_photo');
    } else {
      _photo = photoUrl;
    }
    
    // Notificar a todos los listeners (incluido el menú lateral)
    notifyListeners();
    print('✅ Foto actualizada en context');
  }
  
  // Método para actualizar solo el nombre del usuario
  void updateName(String name) {
    print('\n💼 ACTUALIZANDO NOMBRE EN AUTH CONTEXT');
    print('💼 Nombre: $name');
    
    _name = name;
    
    // Notificar a todos los listeners (incluido el menú lateral)
    notifyListeners();
    print('✅ Nombre actualizado en context');
  }
  
  Future<void> clearUserData() async {
    print('\n🗑️ LIMPIANDO DATOS DE USUARIO');

    // Limpiar datos de todos los BLoCs
    HomeBloc().reset();
    AlertsBloc().reset();
    GuidesBloc().reset();
    MultasBloc().reset();
    ProfileBloc().reset();
    PeakPlateBloc().reset();
    HistorialVehicularBloc().reset();
    SpecialAlertsBloc().reset();
    
    _token = null;
    _name = null;
    _phone = null;
    _photo = null;
    _userId = null;
    
    // Limpiar todas las notificaciones al cerrar sesión
    await NotificationScreen.clearAllNotifications();
    print('🔔 Notificaciones eliminadas');
    
    notifyListeners();
    print('✅ Datos eliminados del context');
  }
}
