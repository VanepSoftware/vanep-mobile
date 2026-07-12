import 'package:webview_flutter/webview_flutter.dart';

/// Clears the browser session state (cookies) held by the in-app WebView.
///
/// OAuth login runs inside a WebView whose cookie jar keeps the backend session
/// (and remember-me) cookie. Clearing the local token session is not enough: a
/// Dio call reaches a different cookie jar, so without wiping the WebView
/// cookies the next `/oauth2/authorize` reuses the live server session and logs
/// the user straight back in without ever showing the login page.
abstract class WebSessionCleaner {
  Future<void> clear();
}

/// [WebSessionCleaner] backed by the platform WebView cookie store shared with
/// [OAuthWebViewPage].
class WebViewWebSessionCleaner implements WebSessionCleaner {
  WebViewWebSessionCleaner(this._cookieManager);

  final WebViewCookieManager _cookieManager;

  @override
  Future<void> clear() => _cookieManager.clearCookies();
}
