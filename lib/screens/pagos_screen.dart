import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PagosScreen extends StatefulWidget {

  const PagosScreen({
    super.key,
  });

  @override
  State<PagosScreen> createState() => _PagosScreen();
}

class _PagosScreen extends State<PagosScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    final url = 'https://micrositios.avalpaycenter.com/equirent-ma';
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
          title: 'Pagos',
          onBackPressed: () => Navigator.pop(context),
        ),
      ),
      body: WebViewWidget(
              controller: controller,
            ),
    );
  }
}
