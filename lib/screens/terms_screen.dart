import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreen();
}

class _TermsScreen extends State<TermsScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    final url = 'https://www.equirent.com.co/home/politica-de-tratamiento-de-datos/';
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
          title: 'Términos y Condiciones',
          onBackPressed: () => Navigator.pop(context),
        ),
      ),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}
