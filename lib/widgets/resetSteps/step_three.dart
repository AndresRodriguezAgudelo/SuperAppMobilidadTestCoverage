import 'package:flutter/material.dart';
import 'package:Equirent_Mobility/widgets/inputs/input_phone.dart';
import '../confirmation_modales.dart';
import '../../BLoC/reset_phone/reset_phone_bloc.dart';

class StepThree extends StatefulWidget {
  final Function(String, bool) onValidate;
  final ResetPhoneBloc resetPhoneBloc;

  const StepThree({
    super.key,
    required this.onValidate,
    required this.resetPhoneBloc,
  });

  @override
  State<StepThree> createState() => StepThreeState();
}

class StepThreeState extends State<StepThree> {
  late ResetPhoneBloc _resetPhoneBloc;
  
  @override
  void initState() {
    super.initState();
    _resetPhoneBloc = widget.resetPhoneBloc;
  }
  bool _isLoading = false;
  String _countryCode = '+57';
  String _phoneNumber = '';
  bool _isPhoneValid = false;

  void _handlePhoneChanged(String phone) {
    setState(() {
      _phoneNumber = phone;
      _isPhoneValid = phone.length >= 10;
    });
    widget.onValidate(_phoneNumber, _isPhoneValid);
  }

  void _handleCountryChanged(String code) {
    setState(() {
      _countryCode = code;
    });
  }
  
  Future<void> updatePhoneNumber() async {
    if (_isLoading || !_isPhoneValid) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Formato completo del teléfono con código de país
      final fullPhone = _phoneNumber;
      
      print('📱 Actualizando número de teléfono: $fullPhone');
      print('📤 Petición enviada al endpoint: actualización de teléfono');
      print('📋 Datos enviados: {"phone": "$_phoneNumber", "userId": "${_resetPhoneBloc.userId}"}');
      
      // Actualizar el número de teléfono en el servidor
      final success = await _resetPhoneBloc.updatePhoneNumber(_phoneNumber);
      
      if (!mounted) return;
      
      if (success) {
        // Si la actualización fue exitosa, solicitar OTP para el nuevo número
        try {
          final otpResponse = await _resetPhoneBloc.requestLoginOTP(_phoneNumber);
          print('✅ OTP solicitado para el nuevo número: $otpResponse');
          
          widget.onValidate(fullPhone, true);
          showConfirmationModal(
            context,
            label: '¡Número actualizado correctamente!',
            attitude: 1,
          );
        } catch (e) {
          print('❌ Error al solicitar OTP para el nuevo número: $e');
          showConfirmationModal(
            context,
            label: 'Número actualizado, pero hubo un error al enviar el código de verificación.',
            attitude: 0,
          );
          // Aún así consideramos que el paso es válido para continuar
          widget.onValidate(fullPhone, true);
        }
      } else {
        widget.onValidate('', false);
        showConfirmationModal(
          context,
          label: 'Error al actualizar el número. ${_resetPhoneBloc.error ?? 'Intenta nuevamente.'}',
          attitude: 0,
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      widget.onValidate('', false);
      showConfirmationModal(
        context,
        label: 'Error al actualizar el número. Por favor intenta nuevamente.',
        attitude: 0,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  void setLoading(bool loading) {
    if (mounted) {
      setState(() => _isLoading = loading);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nuevo número de teléfono',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Te enviaremos un código de verificación para confirmar este número antes de actualizar la cuenta',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 32),
        InputPhone(
          onPhoneChanged: _handlePhoneChanged,
          onCountryChanged: _handleCountryChanged,
          enabled: !_isLoading,
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
