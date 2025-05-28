import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ServiciosScreen extends StatefulWidget {
  final String url;

  const ServiciosScreen({
    super.key,
    required this.url,
  });

  @override
  State<ServiciosScreen> createState() => _ServiciosScreenState();
}

class _ServiciosScreenState extends State<ServiciosScreen> {
  late final WebViewController controller;
  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: TopBar(
          screenType: ScreenType.progressScreen,
          title: 'Servicios',
        ),
      ),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}
