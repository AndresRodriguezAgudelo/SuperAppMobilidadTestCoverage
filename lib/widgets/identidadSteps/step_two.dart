import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:Equirent_Mobility/screens/legal_screen.dart';
import '../inputs/input_text.dart';
import '../inputs/input_city.dart';
import '../inputs/input_checkbox.dart';

class StepTwo extends StatefulWidget {
  final Function(String?, String?, String?, bool) onValidate;
  final bool acceptedTerms;

  const StepTwo({
    super.key,
    required this.onValidate,
    required this.acceptedTerms,
  });

  @override
  State<StepTwo> createState() => _StepTwoState();
}

class _StepTwoState extends State<StepTwo> {
  String? name;
  String? email;
  String? selectedCity;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Crea tu cuenta para continuar',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Completa tu información para disfrutar de todos los beneficios de Equirent App',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 32),
        InputText(
          type: InputType.name,
          label: 'Nombre completo',
          onChanged: (value, isValid) {
            setState(() => name = isValid ? value : null);
            debugPrint('💡 Nombre cambiado - value: $value, isValid: $isValid');
            debugPrint(
                'Estado actual - nombre: $name, email: $email, ciudad: $selectedCity, términos: ${widget.acceptedTerms}');
            widget.onValidate(name, email, selectedCity, widget.acceptedTerms);
          },
        ),
        const SizedBox(height: 16),
        InputText(
          label: 'Correo electrónico',
          type: InputType.email,
          onChanged: (value, isValid) {
            setState(() => email = isValid ? value : null);
            debugPrint('📧 Email cambiado - value: $value, isValid: $isValid');
            debugPrint(
                'Estado actual - nombre: $name, email: $email, ciudad: $selectedCity, términos: ${widget.acceptedTerms}');
            widget.onValidate(name, email, selectedCity, widget.acceptedTerms);
          },
        ),
        const SizedBox(height: 16),
        InputCity(
          label: 'Ciudad',
          onChanged: (value, isValid) {
            setState(() => selectedCity = isValid ? value : null);
            debugPrint(
                '🏙️ Ciudad cambiada - value: $value, isValid: $isValid');
            debugPrint(
                'Estado actual - nombre: $name, email: $email, ciudad: $selectedCity, términos: ${widget.acceptedTerms}');
            widget.onValidate(name, email, selectedCity, widget.acceptedTerms);
          },
        ),
        const SizedBox(height: 16),
        Row(
          spacing: 0,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: InputCheckbox(
                value: widget.acceptedTerms,
                label: 'Acepto los',
                onChanged: (checked) {
                  debugPrint('✅ Términos cambiados - checked: $checked');
                  widget.onValidate(name, email, selectedCity, checked);
                },
              ),
            ),
            SizedBox(
              width: 180,
              child: RichText(
                text: TextSpan(
                  text: 'terminos y politicas',
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
                          builder: (context) => const LegalScreen(),
                        ),
                      );
                    },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),
      ],
    );
  }
}
