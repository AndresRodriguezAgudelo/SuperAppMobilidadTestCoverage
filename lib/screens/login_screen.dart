import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:Equirent_Mobility/widgets/notification_card.dart';
import 'package:Equirent_Mobility/screens/phone_reset_screen.dart';

import '../widgets/button.dart';
import '../widgets/inputs/input_phone.dart';
import '../BLoC/auth/auth.dart';
import '../utils/error_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthBloc _authBloc = AuthBloc();
  bool _isLoading = false;
  String _phoneNumber = '';
  String _countryCode = '+57';

  void _handlePhoneChanged(String phone) {
    setState(() {
      _phoneNumber = phone;
    });
  }

  void _handleCountryChanged(String code) {
    setState(() {
      _countryCode = code;
    });
  }

  String get fullPhoneNumber => _phoneNumber;
  
  bool get _isPhoneValid => _phoneNumber.length >= 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/background.gif',
            fit: BoxFit.cover,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Center(
                    child: Image.asset(
                  'assets/images/logoLogin.png',
                  height: 120,
                  fit: BoxFit.contain,
                )),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 23.0, vertical: 70.0),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.33,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'Vamos a comenzar',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24
                          ),
                        ),
                        const SizedBox(height: 20),
                        InputPhone(
                          onPhoneChanged: _handlePhoneChanged,
                          onCountryChanged: _handleCountryChanged,
                        ),
                        const SizedBox(height: 20),
                        Button(
                          text: 'Ingresar',
                          action: _isLoading || !_isPhoneValid
                              ? null
                              : () async {
                                  setState(() => _isLoading = true);

                                  try {
                                    final response = await _authBloc
                                        .callOTP(fullPhoneNumber);

                                    if (!mounted) return;

                                    if (response['type'] == 'login') {
                                      Navigator.pushNamed(
                                        context,
                                        '/validation',
                                        arguments: {
                                          'phone': fullPhoneNumber,
                                          'user': response['user'],
                                        },
                                      );
                                    } else {
                                      Navigator.pushNamed(
                                        context,
                                        '/registro',
                                        arguments: fullPhoneNumber,
                                      );
                                    }
                                  } catch (e) {
                                    if (!mounted) return;
                                    
                                    // Limpiar el mensaje de error
                                    final cleanedError = ErrorUtils.cleanErrorMessage(e);
                                    
                                    // Mostrar mensaje de error
                                    NotificationCard.showNotification(
                                      context: context,
                                      isPositive: false,
                                      icon: Icons.error,
                                      text: cleanedError,
                                      title: 'Error',
                                      duration: const Duration(seconds: 5),
                                    );
                                  } finally {
                                    if (mounted) {
                                      setState(() => _isLoading = false);
                                    }
                                  }
                                },
                        ),
                        const SizedBox(height: 15),
                        Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          child: RichText(
                            text: TextSpan(
                              text: 'Ya no tengo acceso a mi número',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF38A8E0),
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const PhoneResetScreen(),
                                    ),
                                  );
                                },
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
