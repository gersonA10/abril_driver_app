import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NovedadesPage extends StatefulWidget {
  const NovedadesPage({super.key});

  @override
  State<NovedadesPage> createState() => _NovedadesPageState();
}

class _NovedadesPageState extends State<NovedadesPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://15deabril.macrobyte.site/choferes/blog'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Novedades'),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}