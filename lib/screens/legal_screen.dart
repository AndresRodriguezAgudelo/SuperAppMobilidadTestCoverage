import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../widgets/top_bar.dart';
import 'terms_screen.dart';
import 'privacy_screen.dart';




// asignar propiedades para tenerlos dinamicos



class LegalScreen extends StatefulWidget {
  const LegalScreen({super.key});

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  // 0: Términos y Condiciones, 1: Protección de Datos, 2: Otra opción
  int selectedOption = 0;

  final String termsText = '''
Equirent Vehiculos y Maquinaria SAS BIC, Nit 901.253.015-4, y sus filiales, no se hacen responsables por la información suministrada por las diferentes plataformas de consultas, por lo cual es recomendable validar que los datos del vehículo, ciudad de circulación, número de cedula, entre otros, sean correctos; asi como por las fallas de comunicación que puedan tener estas plataformas de consulta (RUNT, SIMIT, Pico y Placa, entre otras). Equirent Mobility es una APP gratuita cuyo objetivo es el de facilitar la información de requisitos obligatorios y de mantenimiento del vehículo registrado, sin que se genere una relación contractual o compromiso de servicios entre las partes. Si el usuario contrata alguno de los servicios propios o del grupo empresarial, lo hará bajo las condiciones legales y comerciales de cada uno de ellos.

Consulte los T&C aquí: https://www.equirent.com.co/home/politica-de-tratamiento-de-datos/
''';

  final String privacyText = '''
TABLA DE CONTENIDO

1. Introducción
2. Datos de contacto de Equirent, en su calidad de Responsable del Tratamiento
3. Derechos de los Titulares de la Información
4. Deberes de Equirent en su Calidad de Responsable
5. Finalidad de la Recolección de Datos Personales en la Compañía
6. Políticas de Protección de Datos Personales
6.1 Política Superior para la Protección de Datos Personales
6.2 Política Tratamiento Datos Personales recolectados debido a la Pandemia (Covid-19)
6.3 Política para la Actualización, Rectificación, Supresión y Revocatoria de Datos Personales
6.4 Tratamiento de los Datos de Imagen y Video mediante Sistemas de Videovigilancia
6.5 Política tratamiento de Datos de los Menores
6.6 Política Tratamiento de los Datos Personales Sensibles
6.7 Política de Transferencia y Transmisión de Datos Personales
6.8 Política Medidas de Seguridad y Protección de los Datos Personales

Consultela aquí: https://www.equirent.com.co/home/blog/2024/01/20/politicas-sistema-integral-de-proteccion-de-datos-personales-pdp/
''';

  final String otherText = '''
[Contenido pendiente]
''';

  // Construir botón para cada opción
  Widget _buildOptionButton(String text, int optionValue) {
    final bool isSelected = selectedOption == optionValue;
    return TextButton(
      onPressed: () {
        setState(() {
          selectedOption = optionValue;
        });
      },
      style: TextButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFF0E5D9E) : const Color(0xFFE8F7FC),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF0E5D9E),
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
    );
  }

  // Obtener el texto seleccionado
  String _getSelectedText() {
    switch (selectedOption) {
      case 0:
        return termsText.substring(0, termsText.indexOf('https://'));
      case 1:
        return privacyText.substring(0, privacyText.indexOf('https://'));
      case 2:
        return otherText;
      default:
        return termsText.substring(0, termsText.indexOf('https://'));
    }
  }

  // Obtener la URL seleccionada
  String _getSelectedUrl() {
    switch (selectedOption) {
      case 0:
        return 'https://www.equirent.com.co/home/politica-de-tratamiento-de-datos/';
      case 1:
        return 'https://www.equirent.com.co/home/blog/2024/01/20/politicas-sistema-integral-de-proteccion-de-datos-personales-pdp/';
      case 2:
        return 'https://www.equirent.com.co';
      default:
        return 'https://www.equirent.com.co/home/politica-de-tratamiento-de-datos/';
    }
  }

  // Obtener la pantalla de destino
  Widget _getDestinationScreen() {
    switch (selectedOption) {
      case 0:
        return const TermsScreen();
      case 1:
        return const PrivacyScreen();
      case 2:
        // Por ahora, redirigir a TermsScreen para la tercera opción
        return const TermsScreen();
      default:
        return const TermsScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: TopBar(
          screenType: ScreenType.progressScreen,
          title: 'Legal',
          onBackPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Scroll horizontal con opciones
            SizedBox(
              height: 50,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildOptionButton('Términos y Condiciones', 0),
                    const SizedBox(width: 10),
                    _buildOptionButton('Protección de Datos', 1),
                    const SizedBox(width: 10),
                    _buildOptionButton('Política de Privacidad', 2),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            // Área de texto
            Expanded(
              child: SingleChildScrollView(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black),
                    children: [
                      TextSpan(
                        text: _getSelectedText(),
                      ),
                      
                      // Solo mostrar enlace si no es la opción "Otra"
                      if (selectedOption != 2)
                        TextSpan(
                          text: _getSelectedUrl(),
                          style: const TextStyle(
                            color: Color(0xFF38A8E0),
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => _getDestinationScreen(),
                                ),
                              );
                            },
                        ),


                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
