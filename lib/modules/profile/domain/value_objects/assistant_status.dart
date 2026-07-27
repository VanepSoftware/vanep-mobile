enum AssistantStatus {
  unlinked,
  pending,
  active,
  inactive;

  static AssistantStatus? fromApi(Object? raw) {
    if (raw is! String) return null;
    final normalized = raw.trim().toUpperCase();
    if (normalized.isEmpty) return null;
    return switch (normalized) {
      'UNLINKED' => AssistantStatus.unlinked,
      'PENDING' => AssistantStatus.pending,
      'ACTIVE' => AssistantStatus.active,
      'INACTIVE' => AssistantStatus.inactive,
      _ => null,
    };
  }

  static String? toApi(AssistantStatus? status) {
    return switch (status) {
      AssistantStatus.unlinked => 'UNLINKED',
      AssistantStatus.pending => 'PENDING',
      AssistantStatus.active => 'ACTIVE',
      AssistantStatus.inactive => 'INACTIVE',
      null => null,
    };
  }
}
