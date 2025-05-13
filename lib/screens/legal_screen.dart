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
  bool showTerms = true; // true para términos, false para política

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
            // Botones de selección
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        showTerms = true;
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: showTerms ? const Color(0xFF0E5D9E) : const Color(0xFFE8F7FC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Términos y Condiciones',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: showTerms ? Colors.white : const Color(0xFF0E5D9E),
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        showTerms = false;
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: !showTerms ? const Color(0xFF0E5D9E) : const Color(0xFFE8F7FC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Protección de Datos',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: !showTerms ? Colors.white : const Color(0xFF0E5D9E),
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
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
                        text: showTerms 
                          ? termsText.substring(0, termsText.indexOf('https://'))
                          : privacyText.substring(0, privacyText.indexOf('https://')),
                      ),

                      
                      TextSpan(
                        text: showTerms 
                          ? 'https://www.equirent.com.co/home/politica-de-tratamiento-de-datos/'
                          : 'https://www.equirent.com.co/home/blog/2024/01/20/politicas-sistema-integral-de-proteccion-de-datos-personales-pdp/',
                        style: const TextStyle(
                          color: Color(0xFF38A8E0),
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => showTerms 
                                  ? const TermsScreen()
                                  : const PrivacyScreen(),
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
