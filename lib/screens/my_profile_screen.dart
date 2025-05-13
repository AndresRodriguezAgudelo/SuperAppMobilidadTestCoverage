import 'package:flutter/material.dart';
import 'package:Equirent_Mobility/widgets/notification_card.dart';
import 'package:provider/provider.dart';
import '../widgets/top_bar.dart';
import '../widgets/profile_photo.dart';
import 'edit_profile_screen.dart';
import '../widgets/modales.dart';
import '../widgets/loading.dart';
import '../BLoC/profile/profile_bloc.dart';
import '../BLoC/auth/auth_context.dart';

// Importaciones para la funcionalidad de eliminación de cuenta
import '../services/session_manager.dart';
import '../main.dart'; // Para acceder a navigatorKey

// migrar todo a ingles

class MiPerfilScreen extends StatefulWidget {
  const MiPerfilScreen({super.key});

  @override
  State<MiPerfilScreen> createState() => _MiPerfilScreenState();
}

class _MiPerfilScreenState extends State<MiPerfilScreen> {
  int? userId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Obtener el ID del usuario y cargar los datos del perfil después de que el widget se haya construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
  }

  Future<void> _loadProfileData() async {
    final authContext = Provider.of<AuthContext>(context, listen: false);
    final profileBloc = Provider.of<ProfileBloc>(context, listen: false);

    // Obtener el ID del usuario del AuthContext
    userId = authContext.userId;

    print('\n👤 CARGANDO DATOS DEL PERFIL');
    print('🆔 UserId desde AuthContext: $userId');

    if (userId != null) {
      await profileBloc.loadProfile(userId!);
    } else {
      print('⚠️ No se encontró el ID del usuario en el AuthContext');
      // Si no tenemos el userId, podemos mostrar un mensaje de error
      NotificationCard.showNotification(
        context: context,
        isPositive: false,
        icon: Icons.error,
        text: 'No se pudo obtener el ID del usuario',
        date: DateTime.now(),
        title: 'Error',
      );
    }
  }

  Future<void> _handleFieldEdit(EditProfileField field) async {
    final profileBloc = Provider.of<ProfileBloc>(context, listen: false);
    String currentValue = '';

    switch (field) {
      case EditProfileField.name:
        currentValue = profileBloc.name;
        break;
      case EditProfileField.phone:
        currentValue = profileBloc.phone;
        break;
      case EditProfileField.email:
        currentValue = profileBloc.email;
        break;
    }

    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          field: field,
          currentValue: currentValue,
        ),
      ),
    );

    if (result != null && userId != null) {
      // Actualizar el campo en el backend
      String fieldName;
      switch (field) {
        case EditProfileField.name:
          fieldName = 'name';
          break;
        case EditProfileField.phone:
          fieldName = 'phone';
          break;
        case EditProfileField.email:
          fieldName = 'email';
          break;
      }

      setState(() => _isLoading = true);
      
      try {
        // Llamar al método para actualizar el campo en el backend
        final response = await profileBloc.updateProfileField(userId!, fieldName, result);
        
        // Obtener el resultado y mensaje de la respuesta
        final bool success = response['success'] ?? false;
        final String message = response['message'] ?? 'Operación completada';
        
        // Recargar los datos del perfil desde el servidor para asegurar que tenemos la información más actualizada
        print('\n🔄 PERFIL: Recargando datos del perfil después de actualizar $fieldName');
        await _loadProfileData();
        
        // Mostrar notificación con el mensaje de la respuesta
        NotificationCard.showNotification(
          context: context,
          isPositive: success,
          icon: success ? Icons.check_circle : Icons.error,
          text: message,
          date: DateTime.now(),
          title: success ? 'Actualización exitosa' : 'Error',
        );
      } catch (e) {
        // Obtener el mensaje de error o usar uno predeterminado
        String errorMessage = e.toString();
        if (errorMessage.contains('Exception:')) {
          errorMessage = errorMessage.split('Exception:').last.trim();
        }
        
        // Mostrar notificación de error con el mensaje del backend
        NotificationCard.showNotification(
          context: context,
          isPositive: false,
          icon: Icons.error,
          text: errorMessage,
          date: DateTime.now(),
          title: 'Error',
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Widget _buildProfileInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required EditProfileField field,
  }) {
    return InkWell(
      onTap: () => _handleFieldEdit(field),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F7FC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
                width: 45,
                height: 45,
                margin: const EdgeInsets.only(right: 16),
                decoration: const BoxDecoration(
                  color: Color(0xFF38A8E0),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  // Usamos Center para centrar el contenido
                  child: Icon(
                    icon,
                    color: const Color.fromARGB(255, 255, 255, 255),
                    size: 24,
                  ),
                )),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize
                        .min, // Ajusta el tamaño del Row al contenido
                    children: [
                      Flexible(
                        child: Text(
                          value,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis, // Corta con "..."
                          maxLines: 1, // Solo una línea
                        ),
                      ),
                      const SizedBox(width: 4), // Espaciado pequeño
                      if (label == 'Celular')
                        Icon(
                          size: 16,
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                      if (label == 'Correo')
                        Consumer<ProfileBloc>(
                          builder: (context, profileBloc, _) =>
                              profileBloc.verify
                                  ? Icon(
                                      size: 16,
                                      Icons.check_circle,
                                      color: Colors.green,
                                    )
                                  : Icon(
                                      size: 16,
                                      Icons.info,
                                      color: Color(0xFFF5A462),
                                    ),
                        ),
                    ],
                  )
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  void _handleDeleteAccount() {
    CustomModal.show(
      context: context,
      icon: Icons.info,
      iconColor: Colors.red,
      title: '¿Estás seguro de que deseas eliminar tu cuenta?',
      content:
          'Eliminar tu cuenta borrará toda tu información de forma permanente y no podrás recuperarla',
      buttonText: 'Eliminar cuenta',
      buttonColor: Colors.red,
      labelSecondButtonColor: Colors.red,
      secondButtonColor: Colors.white,
      secondButtonText: 'Cancelar',
      onButtonPressed: () async {
        Navigator.pop(context); // Cierra la modal de confirmación

        if (userId != null) {
          final profileBloc = Provider.of<ProfileBloc>(context, listen: false);
          bool success = await profileBloc.deleteAccount(userId!);
          
          // Asegurar que la sesión persistente se limpie
          await SessionManager.clearSession();

          if (success) {
            // Muestra la modal de éxito
            CustomModal.show(
              context: context,
              icon: Icons.check_circle,
              title: 'Cuenta eliminada',
              content: 'Tu cuenta ha sido eliminada exitosamente.',
              buttonText: 'Aceptar',
              onButtonPressed: () {
                // Usar el navigatorKey global para asegurar la navegación
                navigatorKey.currentState?.pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              },
            );
          } else {
            // Mostrar modal de error
            CustomModal.show(
              context: context,
              icon: Icons.error,
              iconColor: Colors.red,
              title: 'Error',
              content:
                  'No se pudo eliminar la cuenta. Por favor, intenta de nuevo más tarde.',
              buttonText: 'Aceptar',
              onButtonPressed: () {
                Navigator.pop(context);
              },
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Loading(
      isLoading: _isLoading,
      child: Consumer<ProfileBloc>(
        builder: (context, profileBloc, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: TopBar(
                title: 'Mi perfil',
                screenType: ScreenType.progressScreen,
              ),
            ),
            body: profileBloc.isLoading
              ? const Center(child: CircularProgressIndicator())
              : profileBloc.error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'Error al cargar el perfil',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _loadProfileData,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Center(
                            child: ProfilePhoto(
                              photoUrl: profileBloc.photo,
                              size: 120,
                              editable: true,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Informacion de la cuenta',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildProfileInfoItem(
                            icon: Icons.person_2_outlined,
                            label: 'Nombre',
                            value: profileBloc.name,
                            field: EditProfileField.name,
                          ),
                          _buildProfileInfoItem(
                            icon: Icons.phone_android_outlined,
                            label: 'Celular',
                            value: profileBloc.phone,
                            field: EditProfileField.phone,
                          ),
                          _buildProfileInfoItem(
                            icon: Icons.email_outlined,
                            label: 'Correo',
                            value: profileBloc.email,
                            field: EditProfileField.email,
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: _handleDeleteAccount,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Eliminar mi cuenta',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 45),
                        ],
                      ),
                    ),
        );
      },
    ));
  }
}
