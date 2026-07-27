enum UserType {
  client,
  driver,
  assistant,
  admin;

  static UserType? fromApi(Object? raw) {
    if (raw is! String) return null;
    final normalized = raw.trim().toUpperCase();
    if (normalized.isEmpty) return null;
    return switch (normalized) {
      'CLIENT' => UserType.client,
      'DRIVER' => UserType.driver,
      'ASSISTANT' => UserType.assistant,
      'ADMIN' => UserType.admin,
      _ => null,
    };
  }

  static String? toApi(UserType? type) {
    return switch (type) {
      UserType.client => 'CLIENT',
      UserType.driver => 'DRIVER',
      UserType.assistant => 'ASSISTANT',
      UserType.admin => 'ADMIN',
      null => null,
    };
  }
}
