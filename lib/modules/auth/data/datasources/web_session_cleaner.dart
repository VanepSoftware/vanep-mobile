import 'package:webview_flutter/webview_flutter.dart';

abstract class WebSessionCleaner {
  Future<void> clear();
}

class WebViewWebSessionCleaner implements WebSessionCleaner {
  WebViewWebSessionCleaner(this._cookieManager);

  final WebViewCookieManager _cookieManager;

  @override
  Future<void> clear() => _cookieManager.clearCookies();
}
