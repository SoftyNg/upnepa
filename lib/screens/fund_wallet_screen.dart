import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FundWalletScreen extends StatefulWidget {
  final String paymentUrl;

  const FundWalletScreen({Key? key, required this.paymentUrl})
      : super(key: key);

  @override
  State<FundWalletScreen> createState() => _FundWalletScreenState();
}

class _FundWalletScreenState extends State<FundWalletScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Complete Payment")),
      body: WebViewWidget(controller: _controller),
    );
  }
}
