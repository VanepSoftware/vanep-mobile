import 'package:flutter/widgets.dart';

import 'package:vanep_mobile/modules/assistant/presentation/pages/assistant_invite_code_page.dart';

String? parseAssistantInviteToken(Uri uri) {
  final isCustomScheme = uri.scheme == 'vanep' &&
      uri.host == 'assistant' &&
      uri.path.contains('invite');

  final isHttps = (uri.scheme == 'https' || uri.scheme == 'http') &&
      uri.host.contains('vanep') &&
      uri.path.contains('assistant/invite');

  if (!isCustomScheme && !isHttps) {
    return null;
  }

  final queryToken = uri.queryParameters['token'] ?? uri.queryParameters['code'];
  if (queryToken != null && queryToken.trim().isNotEmpty) {
    return queryToken.trim();
  }

  if (uri.pathSegments.isNotEmpty) {
    final last = uri.pathSegments.last;
    if (last != 'invite' && last.trim().isNotEmpty) {
      return last.trim();
    }
  }

  return null;
}

Future<void> handleAssistantInviteUri(BuildContext context, Uri uri) async {
  final token = parseAssistantInviteToken(uri);
  if (token != null) {
    await openAssistantInvite(context, initialCode: token);
  }
}
