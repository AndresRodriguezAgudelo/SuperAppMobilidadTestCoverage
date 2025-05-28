import 'dart:async';
import 'package:flutter/material.dart';
import '../inputs/input_code.dart';
import '../../BLoC/auth/auth.dart';
import '../../services/API.dart';
import '../confirmation_modales.dart';

class StepOne extends StatefulWidget {
  final String phoneNumber;
  final Function(String, bool) onValidate;
  // Callback para notificar cambios en el contador
  final VoidCallback? onTimerChanged;

  const StepOne({
    super.key,
    required this.phoneNumber,
    required this.onValidate,
    this.onTimerChanged,
  });

  @override
  State<StepOne> createState() => StepOneState();
}

class StepOneState extends State<StepOne> {
  final AuthBloc _authBloc = AuthBloc();
  bool _isValidating = false;
  bool _isResending = false;
  String _currentCode = '';
  int remainingTime = 59;
  Timer? _timer;
  
  // Getters para exponer el estado al RegisterUserScreen
  bool get isValidating => _isValidating;
  bool get isResending => _isResending;
  int get timerCount => remainingTime;
  bool get canResend => remainingTime == 0 && _currentCode.isEmpty;
  bool get canValidate => _currentCode.length == 4;
  String get currentCode => _currentCode;

  void _onCodeEntered(String code) {
    setState(() {
      _currentCode = code;
    });
    widget.onValidate(code, code.length == 4);
  }
  
  void startTimer() {
    _timer?.cancel();
    setState(() => remainingTime = 59);
    
    // Notificar al padre del cambio en el contador después de setState
    Future.microtask(() {
      if (mounted) widget.onTimerChanged?.call();
    });
    
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (remainingTime == 0) {
          timer.cancel();
          setState(() {}); // Actualizar UI
          
          // Notificar al padre cuando el contador llega a cero
          Future.microtask(() {
            if (mounted) widget.onTimerChanged?.call();
          });
        } else {
          setState(() => remainingTime--);
          
          // Notificar al padre en cada cambio del contador
          Future.microtask(() {
            if (mounted) widget.onTimerChanged?.call();
          });
        }
      },
    );
  }
  
  @override
  void initState() {
    super.initState();
    // Iniciar el temporizador después de que el widget se haya construido completamente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
  
  Future<void> resendOTP() async {
    if (_isResending) return;

    setState(() => _isResending = true);

    try {
      print('📤 Reenviando OTP para teléfono: ${widget.phoneNumber}');
      await _authBloc.callOTP(widget.phoneNumber);
      
      if (mounted) {
        _showNotification(true, 'Código enviado nuevamente');
        startTimer();
      }
    } catch (e) {
      print('❌ Error al reenviar OTP: $e');
      if (e is APIException) {
        print('📝 Detalles del error: ${e.message}');
      }
      if (mounted) {
        _showNotification(false, 'Error al reenviar el código. Por favor intenta nuevamente.');
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
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
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
            children: [
              const TextSpan(
                text: 'Te enviamos un código de 4 dígitos por SMS al número de teléfono ',
              ),
              TextSpan(
                text: '+57 ${widget.phoneNumber}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        InputCode(
          onCompleted: _onCodeEntered,
          enabled: !_isValidating && !_isResending,
        ),
      ],
    );
  }
}
