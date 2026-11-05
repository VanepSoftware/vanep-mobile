import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/environment/environment.dart';

void main() {
  const local = Environment(
    authBaseUrl: 'http://localhost:8080',
    oauthClientId: 'vanep-mobile',
  );

  test('conversationsEndpoint is authBaseUrl plus /api/conversations', () {
    expect(
      local.conversationsEndpoint,
      'http://localhost:8080/api/conversations',
    );
  });

  test('conversationMessagesEndpoint nests messages under the token', () {
    expect(
      local.conversationMessagesEndpoint('abc123'),
      'http://localhost:8080/api/conversations/abc123/messages',
    );
  });

  test('conversationsWebSocketUrl swaps http for ws', () {
    expect(local.conversationsWebSocketUrl, 'ws://localhost:8080/api/ws');
  });

  test('conversationsWebSocketUrl swaps https for wss', () {
    const production = Environment(
      authBaseUrl: 'https://api.vanep.com.br',
      oauthClientId: 'vanep-mobile',
    );

    expect(
      production.conversationsWebSocketUrl,
      'wss://api.vanep.com.br/api/ws',
    );
  });
}
