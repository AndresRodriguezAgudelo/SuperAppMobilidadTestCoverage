import 'package:flutter/material.dart';
import '../confirmation_modales.dart';
import '../inputs/input_text.dart';
import '../../BLoC/reset_phone/reset_phone_bloc.dart';

class StepOne extends StatefulWidget {
  final Function(String, bool) onValidate;
  final ResetPhoneBloc resetPhoneBloc;

  const StepOne({
    super.key,
    required this.onValidate,
    required this.resetPhoneBloc,
  });

  @override
  State<StepOne> createState() => StepOneState();
}

class StepOneState extends State<StepOne> {
  late ResetPhoneBloc _resetPhoneBloc;
  bool _isLoading = false;
  String _email = '';
  bool _isEmailValid = false;
  
  @override
  void initState() {
    super.initState();
    _resetPhoneBloc = widget.resetPhoneBloc;
  }
  
  Future<void> validateOTP() async {
    if (_isLoading || !_isEmailValid) return;
    
    setState(() => _isLoading = true);
    
    try {
      print('📧 Solicitando código de recuperación para el email: $_email');
      print('📤 Petición enviada al endpoint: recuperación de cuenta');
      print('📋 Datos enviados: {"email": "$_email"}');
      
      final success = await _resetPhoneBloc.requestRecoveryCode(_email);
      
      if (!mounted) return;
      
      if (success) {
        widget.onValidate(_email, true);
        showConfirmationModal(
          context,
          label: '¡Código enviado correctamente!',
          attitude: 1,
        );
      } else {
        widget.onValidate('', false);
        showConfirmationModal(
          context,
          label: 'Error al enviar el código. ${_resetPhoneBloc.error ?? 'Intenta nuevamente.'}',
          attitude: 0,
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      widget.onValidate('', false);
      showConfirmationModal(
        context,
        label: 'Error al enviar el código. Por favor intenta nuevamente.',
        attitude: 0,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  void _handleEmailChanged(String value, bool isValid) {
    setState(() {
      _email = value;
      _isEmailValid = isValid;
    });
    widget.onValidate(value, isValid);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ingresa tu correo registrado',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Para recuperar tu cuenta, enviaremos un código de verificación al correo asociado',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 32),
        InputText(
          label: 'Correo electrónico', 
          type: InputType.email,
          onChanged: _handleEmailChanged,
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
