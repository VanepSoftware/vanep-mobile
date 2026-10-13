import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/assistant/presentation/utils/assistant_invite_deeplink.dart';

void main() {
  group('parseAssistantInviteToken', () {
    test('extracts token from custom scheme vanep://assistant/invite?token=...', () {
      final uri = Uri.parse('vanep://assistant/invite?token=ABC123');
      expect(parseAssistantInviteToken(uri), 'ABC123');
    });

    test('extracts code from custom scheme vanep://assistant/invite?code=...', () {
      final uri = Uri.parse('vanep://assistant/invite?code=XYZ456');
      expect(parseAssistantInviteToken(uri), 'XYZ456');
    });

    test('extracts token from universal link query parameter', () {
      final uri = Uri.parse('https://vanep.com.br/assistant/invite?token=SEC789');
      expect(parseAssistantInviteToken(uri), 'SEC789');
    });

    test('extracts token from universal link path segment', () {
      final uri = Uri.parse('https://vanep.com.br/assistant/invite/TOK999');
      expect(parseAssistantInviteToken(uri), 'TOK999');
    });

    test('returns null for unrelated URIs', () {
      expect(parseAssistantInviteToken(Uri.parse('https://google.com')), isNull);
      expect(parseAssistantInviteToken(Uri.parse('vanep://client/home')), isNull);
      expect(parseAssistantInviteToken(Uri.parse('vanep://assistant/other')), isNull);
    });
  });
}
