import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreen();
}

class _PrivacyScreen extends State<PrivacyScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    final url = 'https://www.equirent.com.co/home/blog/2024/01/20/politicas-sistema-integral-de-proteccion-de-datos-personales-pdp/';
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: TopBar(
          screenType: ScreenType.progressScreen,
          title: 'Política de Protección de Datos',
          onBackPressed: () => Navigator.pop(context),
        ),
      ),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}
