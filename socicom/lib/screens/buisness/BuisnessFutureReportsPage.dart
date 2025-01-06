import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class BusinessFutureReportsPage extends StatefulWidget {
  final String futureReportId; // Firebase'deki belge ID'si

  const BusinessFutureReportsPage({super.key, required this.futureReportId});

  @override
  _BusinessFutureReportsPageState createState() =>
      _BusinessFutureReportsPageState();
}

class _BusinessFutureReportsPageState extends State<BusinessFutureReportsPage> {
  late final WebViewController _controller;
  String? embedUrl;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _fetchEmbedUrlFromFirebase();
  }

  void _initializeWebView() {
    late final PlatformWebViewControllerCreationParams params;

    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('Navigation request to: ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      );

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
  }

  Future<void> _fetchEmbedUrlFromFirebase() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Future_reports') // Koleksiyon adı değiştirildi
          .doc(widget.futureReportId) // Belge ID'si future_reportId olarak değiştirildi
          .get();

      if (doc.exists && doc.data()!.containsKey('embedUrl')) {
        setState(() {
          Uri uri = Uri.parse(doc['embedUrl']);
          embedUrl = uri.replace(queryParameters: {
            ...uri.queryParameters,
            'isMobile': 'true', // Mobil uyum için parametre ekleniyor
            'autoAuth': 'true', // Otomatik giriş desteği için ekleniyor
          }).toString();
        });

        _controller.loadRequest(Uri.parse(embedUrl!));
      } else {
        debugPrint('Embed URL not found in Firestore');
      }
    } catch (e) {
      debugPrint('Error fetching embed URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Future Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (embedUrl != null) {
                _controller.reload();
              }
            },
          ),
        ],
      ),
      body: embedUrl == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : WebViewWidget(controller: _controller),
    );
  }
}
