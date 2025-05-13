import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/button.dart';
import '../widgets/top_bar.dart';
import '../widgets/inputs/input_code.dart';
import '../BLoC/auth/auth.dart';
import '../BLoC/home/home_bloc.dart';
import '../widgets/confirmation_modales.dart'; // Agregado import del widget InputCode

class ValidationCodeScreen extends StatefulWidget {
  const ValidationCodeScreen({super.key});

  @override
  State<ValidationCodeScreen> createState() => _ValidationCodeScreenState();
}

class _ValidationCodeScreenState extends State<ValidationCodeScreen> {
  final AuthBloc _authBloc = AuthBloc();
  final HomeBloc _homeBloc = HomeBloc();
  late String phoneNumber;
  late String userName;
  int remainingTime = 59;
  bool _isLoading = false;
  bool _isValidating = false;
  String? _code;
  Timer? _timer;
  
  void startTimer() {
    _timer?.cancel();
    setState(() => remainingTime = 59);
    
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (remainingTime == 0) {
          timer.cancel();
        } else {
          setState(() => remainingTime--);
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic> args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    phoneNumber = args['phone'] ?? '';
    userName = args['user'] ?? 'Usuario';
  }

  Future<void> _validateCode() async {
    if (_isValidating || _code == null) return;

    setState(() => _isValidating = true);

    try {
      print('🔑 Validando código: $_code para teléfono: $phoneNumber');
      final response = await _authBloc.validateOTP(_code!, phoneNumber);
      print('📡 Respuesta completa: $response');
      
      if (!mounted) return;

      // Extraer nombre del usuario para el mensaje
      final userName = response['user']?['name'] ?? 'Usuario';
      
      // Habilitar las peticiones después del login exitoso
      _homeBloc.enableRequests();
      print('🔓 PETICIONES HABILITADAS después del login exitoso');
      
      // Mostrar modal de éxito
      showConfirmationModal(
        context,
        label: '¡Bienvenido $userName!',
        attitude: 1,
      );

      // Esperar un momento para que se vea el modal
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Navegar al home
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print('❌ Error en validación/login: $e');
      if (!mounted) return;

      showConfirmationModal(
        context,
        label: 'Error de autenticación. Por favor intenta nuevamente.',
        attitude: 0,
      );
    } finally {
      if (mounted) {
        setState(() => _isValidating = false);
      }
    }
  }

  Future<void> _resendCode() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      await _authBloc.callOTP(phoneNumber);
      
      if (!mounted) return;

      showConfirmationModal(
        context,
        label: 'Código enviado nuevamente',
        attitude: 1,
      );

      startTimer();
    } catch (e) {
      if (!mounted) return;

      showConfirmationModal(
        context,
        label: 'Error al reenviar el código',
        attitude: 0,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canValidate = _code?.length == 4;
    final bool canResend = remainingTime == 0 && !canValidate;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SafeArea(
            child: TopBar(
              screenType: ScreenType.progressScreen,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hola ${userName.split(' ')[0]},',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Te damos la bienvenida nuevamente',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Te enviamos un código de 4 dígitos por SMS al número de teléfono $phoneNumber',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 32),
                  InputCode(
                    onCompleted: (code) {
                      setState(() => _code = code);
                      debugPrint('🔑 Código ingresado: $code');
                    },
                  ),
                  const Spacer(),
                  Center(
                    child: Button(
                      text: canValidate
                          ? 'Validar'
                          : canResend
                              ? 'Reenviar código'
                              : 'Reenviar en $remainingTime',
                      action: canValidate
                          ? (_isValidating ? null : _validateCode)
                          : (canResend ? (_isLoading ? null : _resendCode) : null),
                      isLoading: _isValidating || _isLoading,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
