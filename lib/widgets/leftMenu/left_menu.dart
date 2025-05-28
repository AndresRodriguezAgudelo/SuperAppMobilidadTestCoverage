import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:Equirent_Mobility/BLoC/alerts/alerts_bloc.dart';
// import 'package:Equirent_Mobility/BLoC/guides/guides_bloc.dart';
// import 'package:Equirent_Mobility/BLoC/historial_vehicular/historial_vehicular_bloc.dart';
// import 'package:Equirent_Mobility/BLoC/home/home_bloc.dart';
// import 'package:Equirent_Mobility/BLoC/multas/multas_bloc.dart';
// import 'package:Equirent_Mobility/BLoC/pick_and_plate/pick_and_plate_bloc.dart';
// import 'package:Equirent_Mobility/BLoC/profile/profile_bloc.dart';
// import 'package:Equirent_Mobility/BLoC/special_alerts/special_alerts_bloc.dart';
import '../modales.dart';
import '../profile_photo.dart';
// No necesitamos importar nada de main.dart para esta solución

import '../../BLoC/auth/auth_context.dart';
import '../../services/session_manager.dart';
import '../../services/API.dart';
import '../../screens/my_vehicles_screen.dart';
import '../../screens/guias_screen.dart';
import '../../screens/our_services_screen.dart';
import '../../screens/pagos_screen.dart';
import '../../screens/legal_screen.dart';
import '../../main.dart';

class LeftMenu extends StatelessWidget {
  const LeftMenu({super.key});

  Widget _buildProfileSection(BuildContext context) {
    return Consumer<AuthContext>(
      builder: (context, authContext, child) {
        return Column(
          children: [
            // Usar el widget ProfilePhoto para mostrar la foto de perfil
            ProfilePhoto(
              photoUrl: authContext.photo,
              size: 100,
              editable: false,
            ),
            const SizedBox(height: 16),
            Transform.translate(
              offset: const Offset(0, 10), // Mueve el texto 10px hacia abajo
              child: Text(
                '¡Hola ${(authContext.name == null || authContext.name!.isEmpty) ? 'Usuario' : authContext.name}!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/mi_perfil');
              },
              child: const Text(
                'Ir a mi perfil',
                style: TextStyle(
                    color: Color(0xFF2FA8E0),
                    fontWeight: FontWeight.w700,
                    fontSize: 18),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNavigationOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Widget screen,
  }) {
    return Container(
      height: 65,
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F7FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF38A8E0),
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Si estamos en el home, usar pushReplacement para forzar la recarga
          if (ModalRoute.of(context)?.settings.name == '/') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => screen),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => screen),
            );
          }
        },
      ),
    );
  }



  /// Método para manejar la navegación a la pantalla de pagos
  /// Este método llama al endpoint queryHistory antes de navegar
  /// Simplemente registra en el backend cuando un usuario entra a la web view de pagos
  Future<void> _handlePaymentsNavigation(BuildContext context) async {
    // Obtener el token de autenticación
    final authContext = Provider.of<AuthContext>(context, listen: false);
    final token = authContext.token;
    
    // Llamar al endpoint queryHistory sin mostrar modales
    if (token != null && token.isNotEmpty) {
      // Crear instancia de APIService
      final apiService = APIService();
      
      // Disparar el POST al endpoint (no esperamos la respuesta)
      // Lo ejecutamos en paralelo para no bloquear la navegación
      apiService.queryHistory(token: token);
    }
    
    // Navegar directamente a la pantalla de pagos sin esperar la respuesta
    if (ModalRoute.of(context)?.settings.name == '/') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PagosScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PagosScreen()),
      );
    }
  }

  Widget _buildNavigationSection() {
    return Builder(
      builder: (context) => SingleChildScrollView(
        child: Column(
          children: [
            _buildNavigationOption(
              context: context,
              icon: Icons.directions_car_filled_outlined,
              label: 'Mis vehiculos',
              screen: const MisVehiculosScreen(),
            ),
            _buildNavigationOption(
              context: context,
              icon: Icons.map_outlined,
              label: 'Guias',
              screen: const GuiasScreen(),
            ),
            _buildNavigationOption(
              context: context,
              icon: Icons.construction,
              label: 'Servicios',
              screen: OurServiciosScreen(),
            ),
            // Opción especial de Pagos con manejo personalizado
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F7FC),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                leading: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Círculo principal con el icono
                    const CircleAvatar(
                      backgroundColor: Color(0xFF0E5D9D),
                      radius: 20,
                      child: Icon(Icons.credit_card, color: Colors.white),
                    ),
                    // Círculo pequeño con estrella en la esquina superior derecha
                    Positioned(
                      top: -5,
                      right: 25,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4A261),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: const Icon(
                          Icons.star,
                          size: 12,
                          color: Color(0xFFFDECDE),
                        ),
                      ),
                    ),
                  ],
                ),
                title: const Text(
                  'Pagos',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Exclusivo Clientes Equirent',
                  style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _handlePaymentsNavigation(context),
              ),
            ),
            _buildNavigationOption(
              context: context,
              icon: Icons.info_outline,
              label: 'Legal',
              screen: const LegalScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Consumer<AuthContext>(
      builder: (context, authContext, child) {
        return TextButton.icon(
          onPressed: () {
            // Mostrar diálogo de confirmación antes de cerrar sesión
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return CustomModal(
                  icon: Icons.info_outline,
                  iconColor: Color.fromARGB(255, 255, 255, 255),
                  title: '¿Estás seguro de que deseas cerrar sesión?',
                  content:
                      'Cerrar sesión podría interrumpir tu experiencia o hacer que pierdas avances en tus gestiones',
                  secondButtonText: 'Cancelar',
                  onSecondButtonPressed: () {
                    Navigator.of(context).pop();
                  },
                  buttonText: 'Cerrar sesión',
                  secondButtonColor: Colors.white,
                  labelSecondButtonColor: Color(0xFF2FA8E0),
                  onButtonPressed: () async {
                    // Cierra el modal
                    Navigator.of(context).pop();

                    // Limpiar sesión persistida y datos de usuario
                    debugPrint('LEFT_MENU: Clearing persisted session...');
                    await SessionManager.clearSession();
                    await authContext.clearUserData();
                    
                    // Cierra el Drawer si está abierto
                    final scaffoldState = Scaffold.maybeOf(context);
                    if (scaffoldState != null && scaffoldState.isDrawerOpen) {
                      Navigator.of(context).pop(); // Cierra el Drawer
                    }

                    // Esperar un momento para asegurar que el Drawer se cierre
                    await Future.delayed(const Duration(milliseconds: 300));

                    // Usar el navigatorKey global para asegurar que la navegación funcione
                    // incluso si el contexto original ya no es válido
                    debugPrint('LEFT_MENU: Navegando al login usando navigatorKey global');
                    navigatorKey.currentState?.pushNamedAndRemoveUntil(
                      '/login',
                      (route) => false, // Elimina todas las rutas anteriores
                    );
                  },
                );
              },
            );
          },
          icon: const Icon(
            Icons.logout,
            color: Color(0xFF1E3340),
          ),
          label: const Text(
            'Cerrar sesión',
            style: TextStyle(
              color: Color(0xFF1E3340),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 335,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildProfileSection(context),
              const SizedBox(height: 32),
              Expanded(
                child: _buildNavigationSection(),
              ),
              const SizedBox(height: 32),
              _buildLogoutButton(context),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
