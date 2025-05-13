import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';
import '../widgets/button.dart';
import '../widgets/inputs/input_text.dart';
import '../widgets/inputs/input_phone.dart';
import '../widgets/modales.dart';
import '../BLoC/auth/auth.dart';
import '../BLoC/profile/profile_bloc.dart';
import '../widgets/inputs/input_code.dart';
import '../BLoC/auth/auth_context.dart';
import '../services/API.dart';
import '../widgets/loading.dart';

enum EditProfileField {
  name,
  phone,
  email,
}

class EditProfileScreen extends StatefulWidget {
  final EditProfileField field;
  final String currentValue;

  const EditProfileScreen({
    super.key,
    required this.field,
    required this.currentValue,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthBloc _authBloc = AuthBloc();
  final ProfileBloc _profileBloc = ProfileBloc();
  final AuthContext _authContext = AuthContext();
  final APIService _apiService = APIService();
  String? newValue;
  String? selectedCountryCode = '+57';
  bool isValid = false;
  bool showVerification = false;
  bool _isLoading = false;
  bool _isValidating = false;
  
  // Variables para el temporizador de OTP
  int _remainingSeconds = 60;
  Timer? _timer;
  String? _otpCode;
  bool _isResendingOtp = false;

  String get _getTitle {
    if (widget.field == EditProfileField.phone && showVerification) {
      return 'Verificar teléfono';
    }
    switch (widget.field) {
      case EditProfileField.name:
        return 'Editar nombre';
      case EditProfileField.phone:
        return 'Editar teléfono';
      case EditProfileField.email:
        return 'Editar correo';
    }
  }

  void _handleValidation(String value, bool valid) {
    setState(() {
      newValue = valid ? value : null;
      isValid = valid;
    });
  }

  void _handlePhoneChanged(String phone) {
    setState(() {
      newValue = phone;
      isValid = phone.length >= 10;
    });
  }

  void _handleCountryChanged(String countryCode) {
    setState(() {
      selectedCountryCode = countryCode;
    });
  }

  void _handlePhoneVerification(String code) {
    setState(() {
      _otpCode = code;
    });
    // Solo guardamos el código, la validación se hará al presionar el botón
  }
  
  // Método para validar el OTP y actualizar el perfil
  Future<void> _validateAndUpdatePhone() async {
    if (_isValidating || _otpCode == null || _otpCode!.length != 4) return;
    
    setState(() => _isValidating = true);
    
    try {
      // 1. Validar el OTP
      final fullPhone = newValue!;
      final validationResponse = await _apiService.post(
        _apiService.validateOTPEndpoint,
        body: {
          "otp": _otpCode,
        },
      );
      
      print('✅ OTP validado correctamente: $validationResponse');
      
      // 2. Actualizar el perfil del usuario con el nuevo teléfono
      final userId = _authContext.userId;
      if (userId != null) {
        final updateResult = await _profileBloc.updateUserProfile(
          userId, 
          {"phone": fullPhone}
        );
        
        if (mounted) {
          if (updateResult) {
            CustomModal.show(
              context: context,
              icon: Icons.check_circle,
              title: 'Cambio exitoso',
              content: 'Tu número de teléfono ha sido actualizado correctamente.',
              buttonText: 'Aceptar',
              onButtonPressed: () {
                Navigator.pop(context); // Cierra la modal
                Navigator.pop(context, newValue); // Regresa a la pantalla anterior con el nuevo valor
              },
            );
          } else {
            throw Exception('No se pudo actualizar el perfil');
          }
        }
      } else {
        throw Exception('No se encontró el ID del usuario');
      }
    } catch (e) {
      print('❌ Error en validación/actualización: $e');
      if (mounted) {
        CustomModal.show(
          context: context,
          icon: Icons.error,
          title: 'Error de verificación',
          content: 'El código ingresado no es válido o ha expirado. Por favor intenta nuevamente.',
          buttonText: 'Aceptar',
          onButtonPressed: () {
            Navigator.pop(context); // Cierra la modal
          },
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isValidating = false);
      }
    }
  }

  void _startOtpTimer() {
    // Cancelar timer existente si hay uno
    _timer?.cancel();
    
    // Reiniciar contador
    setState(() => _remainingSeconds = 60);
    
    // Iniciar nuevo timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }
  
  Future<void> _resendOtp() async {
    if (_isResendingOtp) return;
    
    setState(() => _isResendingOtp = true);
    
    try {
      final fullPhone = newValue!;
      await _authBloc.callOTP(fullPhone);
      
      if (mounted) {
        _startOtpTimer();
        
        CustomModal.show(
          context: context,
          icon: Icons.check_circle,
          title: 'Código enviado',
          content: 'Se ha enviado un nuevo código de verificación a tu número.',
          buttonText: 'Aceptar',
          onButtonPressed: () {
            Navigator.pop(context);
          },
        );
      }
    } catch (e) {
      if (mounted) {
        CustomModal.show(
          context: context,
          icon: Icons.error,
          title: 'Error',
          content: 'No se pudo enviar el código de verificación. Por favor intenta nuevamente.',
          buttonText: 'Aceptar',
          onButtonPressed: () {
            Navigator.pop(context);
          },
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResendingOtp = false);
      }
    }
  }

  void _handleSave() async {
    if (!isValid || newValue == null) return;

    if (widget.field == EditProfileField.phone) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Llamar al OTP con el nuevo número de teléfono
        final fullPhone = newValue!;
        await _authBloc.callOTP(fullPhone);
        
        if (mounted) {
          setState(() {
            showVerification = true;
            _isLoading = false;
          });
          
          // Iniciar temporizador para reenvío de OTP
          _startOtpTimer();
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          
          // Mostrar error
          CustomModal.show(
            context: context,
            icon: Icons.error,
            title: 'Error',
            content: 'No se pudo enviar el código de verificación. Por favor intenta nuevamente.',
            buttonText: 'Aceptar',
            onButtonPressed: () {
              Navigator.pop(context); // Cierra la modal
            },
          );
        }
      }
    } else {
      // Usar NotificationCard en lugar de CustomModal para mostrar la respuesta del backend
      // y navegar de vuelta a la pantalla anterior con el nuevo valor
      Navigator.pop(context, newValue);
      
      // La notificación se mostrará en la pantalla anterior (my_profile_screen)
      // cuando reciba el resultado y procese la actualización del perfil
    }
  }

  Widget _buildContent() {
    if (widget.field == EditProfileField.phone && showVerification) {
      // Determinar si el botón debe estar habilitado
      bool canValidate = _otpCode != null && _otpCode!.length == 4;
      bool canResend = _remainingSeconds <= 0 && !canValidate && !_isResendingOtp;
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y texto informativo
          const Text(
            'Verificacion de identidad',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Te enviamos un código de 4 dígitos por SMS al número de teléfono ${newValue ?? widget.currentValue}',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          
          // Input para el código OTP
          InputCode(
            onCompleted: (code) => _handlePhoneVerification(code),
            enabled: !_isValidating && !_isResendingOtp,
          ),
          
          // Espaciador para empujar el botón hacia abajo
          const Spacer(),
          
          // Botón de validación o reenvío
          Center(
            child: Button(
              text: canValidate 
                  ? 'Validar' 
                  : canResend 
                      ? 'Reenviar código' 
                      : 'Reenviar en $_remainingSeconds s',
              action: canValidate 
                  ? (_isValidating ? null : _validateAndUpdatePhone)
                  : (canResend ? _resendOtp : null),
              isLoading: _isValidating || _isResendingOtp,
            ),
          ),
          const SizedBox(height: 32),
        ],
      );
    }

    if (widget.field == EditProfileField.phone) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 24.0),
            child: Text(
              'Para cambiar su número de telefono puede digitar uno nuevo y deberá realizar la validación. Recuerde que al cambiar el número se modificará el acceso, las notificaciones y demás funcionalidades asociadas.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
          InputPhone(
            onPhoneChanged: _handlePhoneChanged,
            onCountryChanged: _handleCountryChanged,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 24.0),
          child: Text(
            widget.field == EditProfileField.name ? 
            'Información básica: Digite su no﻿mbre y apellidos.'
            : 'Para cambiar la cuenta de correo puede digitar una nueva y deberá realizar la validación.  Recuerde que al cambiar la cuenta de correo se modificarán las notificaciones y demás funcionalidades asociadas.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
        InputText(
          type: widget.field == EditProfileField.email ? InputType.email : InputType.name,
          label: widget.field == EditProfileField.name ? 'Nombre completo' : 'Correo electrónico',
          defaultValue: widget.currentValue,
          onChanged: _handleValidation,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Loading(
      isLoading: _isLoading,
      child: Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: TopBar(
          title: _getTitle,
          screenType: ScreenType.progressScreen,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildContent(),
            ),
            const SizedBox(height: 16), // Espacio entre el contenido y el botón
            if (!showVerification) Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32.0), // Padding inferior para subir el botón
                child: Button(
                  text: 'Guardar',
                  action: isValid && !_isLoading ? _handleSave : null,
                  isLoading: _isLoading,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
