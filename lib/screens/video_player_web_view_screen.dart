import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';


class VideoPlayerWebViewScreen extends StatefulWidget {
  final String url;
  
  const VideoPlayerWebViewScreen({
    super.key,
    required this.url,
  });

  @override
  State<VideoPlayerWebViewScreen> createState() => _VideoPlayerWebViewScreenState();
}

class _VideoPlayerWebViewScreenState extends State<VideoPlayerWebViewScreen> {
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
          title: 'Video',
        ),
      ),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}
