import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SimitWebViewScreen extends StatefulWidget {
  final String placa;
  
  const SimitWebViewScreen({
    super.key,
    required this.placa,
  });

  @override
  State<SimitWebViewScreen> createState() => _SimitWebViewScreenState();
}

class _SimitWebViewScreenState extends State<SimitWebViewScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    final url = 'https://www.fcm.org.co/simit/#/estado-cuenta?numDocPlacaProp=${widget.placa}';
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
          title: 'SIMIT',
          onBackPressed: () => Navigator.pop(context),
        ),
      ),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}
