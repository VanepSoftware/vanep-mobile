class AccessTokenSource {
  const AccessTokenSource({
    required this.readAccessToken,
    required this.refreshAccessToken,
  });

  final Future<String?> Function() readAccessToken;

  final Future<String?> Function() refreshAccessToken;
}
