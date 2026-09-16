enum ConfirmationSource {
  driver,
  assistant;

  static ConfirmationSource? fromApi(Object? raw) {
    if (raw is! String) return null;
    final normalized = raw.trim().toUpperCase();
    return switch (normalized) {
      'DRIVER' => ConfirmationSource.driver,
      'ASSISTANT' => ConfirmationSource.assistant,
      _ => null,
    };
  }

  static String? toApi(ConfirmationSource? source) {
    return switch (source) {
      ConfirmationSource.driver => 'DRIVER',
      ConfirmationSource.assistant => 'ASSISTANT',
      null => null,
    };
  }
}
