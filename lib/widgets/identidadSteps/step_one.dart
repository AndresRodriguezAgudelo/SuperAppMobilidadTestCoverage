import 'package:flutter/material.dart';
import '../inputs/input_code.dart';
import '../../BLoC/auth/auth.dart';
import '../../services/API.dart';
import '../confirmation_modales.dart';

class StepOne extends StatefulWidget {
  final String phoneNumber;
  final Function(String, bool) onValidate;

  const StepOne({
    super.key,
    required this.phoneNumber,
    required this.onValidate,
  });

  @override
  State<StepOne> createState() => StepOneState();
}

class StepOneState extends State<StepOne> {
  final AuthBloc _authBloc = AuthBloc();
  bool _isValidating = false;
  String _currentCode = '';

  void _onCodeEntered(String code) {
    _currentCode = code;
    widget.onValidate(code, code.length == 4);
  }

  Future<void> validateOTP() async {
    if (_isValidating || _currentCode.length != 4) return;

    setState(() => _isValidating = true);

    try {
      print('🔑 Validando OTP: $_currentCode para teléfono: ${widget.phoneNumber}');
      final response = await _authBloc.validateOTP(_currentCode, widget.phoneNumber, isNewUser: true);
      print('✅ Respuesta exitosa: $response');
      
      if (mounted) {
        widget.onValidate(_currentCode, true);
        _showNotification(true, '¡Código validado correctamente!');
      }
    } catch (e) {
      print('❌ Error en validación OTP: $e');
      if (e is APIException) {
        print('📝 Detalles del error: ${e.message}');
      }
      if (mounted) {
        _showNotification(false, 'Error de autenticación. Por favor intenta nuevamente.');
        widget.onValidate('', false);
      }
    } finally {
      if (mounted) {
        setState(() => _isValidating = false);
      }
    }
  }

  void _showNotification(bool isPositive, String message) {
    showConfirmationModal(
      context,
      attitude: isPositive ? 1 : 0,
      label: message,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Verificacion de identidad',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Te enviamos un código de 4 dígitos por SMS al número de teléfono ${widget.phoneNumber}',
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 32),
        InputCode(
          onCompleted: _onCodeEntered,
          enabled: !_isValidating,
        ),
      ],
    );
  }
}
