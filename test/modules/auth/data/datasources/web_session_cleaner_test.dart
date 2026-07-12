import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/auth/data/datasources/web_session_cleaner.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MockWebViewCookieManager extends Mock implements WebViewCookieManager {}

void main() {
  test('clear() wipes the WebView cookie store', () async {
    final cookieManager = MockWebViewCookieManager();
    when(cookieManager.clearCookies).thenAnswer((_) async => true);

    await WebViewWebSessionCleaner(cookieManager).clear();

    verify(cookieManager.clearCookies).called(1);
  });
}
