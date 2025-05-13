import 'package:flutter/material.dart';
import '../inputs/input_code.dart';
import '../../services/API.dart';
import '../confirmation_modales.dart';
import '../../BLoC/reset_phone/reset_phone_bloc.dart';

class StepFour extends StatefulWidget {
  final String phoneNumber;
  final Function(String, bool) onValidate;
  final ResetPhoneBloc resetPhoneBloc;

  const StepFour({
    super.key,
    required this.phoneNumber,
    required this.onValidate,
    required this.resetPhoneBloc,
  });

  @override
  State<StepFour> createState() => StepFourStatus();
}

class StepFourStatus extends State<StepFour> {
  late ResetPhoneBloc _resetPhoneBloc;
  
  @override
  void initState() {
    super.initState();
    _resetPhoneBloc = widget.resetPhoneBloc;
  }
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
      print('🔑 Validando OTP de login: $_currentCode para teléfono: ${widget.phoneNumber}');
      final success = await _resetPhoneBloc.validateLoginOTP(_currentCode, widget.phoneNumber);
      
      if (!mounted) return;
      
      if (success) {
        print('✅ Login exitoso, redirigiendo al home');
        widget.onValidate(_currentCode, true);
        _showNotification(true, '¡Código validado correctamente!');
      } else {
        print('❌ Error en validación OTP: ${_resetPhoneBloc.error}');
        widget.onValidate('', false);
        _showNotification(false, 'Código inválido. Por favor intenta nuevamente.');
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
