import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/value_objects/authorization_request.dart';
import 'oauth_redirect.dart';

/// Hosts the backend login page in an in-app WebView and captures the OAuth
/// authorization code by intercepting the navigation to the custom-scheme
/// redirect URI. Pops with the `code` on success, or `null` when cancelled or
/// the `state` does not match.
class OAuthWebViewPage extends StatefulWidget {
  const OAuthWebViewPage({required this.request, super.key});

  final AuthorizationRequest request;

  @override
  State<OAuthWebViewPage> createState() => _OAuthWebViewPageState();
}

class _OAuthWebViewPageState extends State<OAuthWebViewPage> {
  late final WebViewController _controller;
  bool _completed = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (isOAuthRedirect(request.url, widget.request.redirectUri)) {
              _finish(extractAuthorizationCode(request.url, widget.request));
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.request.authorizationUrl));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.loginTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _finish(null),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const LinearProgressIndicator(),
        ],
      ),
    );
  }

  void _finish(String? code) {
    if (_completed) return;
    _completed = true;
    Navigator.of(context).pop(code);
  }
}
