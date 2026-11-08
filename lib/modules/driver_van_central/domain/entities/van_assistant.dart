enum VanAssistantStatus { unlinked, pending, active, inactive }

abstract class VanAssistant {
  String get token;

  String get name;

  VanAssistantStatus get status;
}

extension VanAssistantWork on VanAssistant {
  bool get isWorking => status == VanAssistantStatus.active;
}

extension VanAssistantTeam on List<VanAssistant> {
  List<VanAssistant> get working => [
    for (final assistant in this)
      if (assistant.isWorking) assistant,
  ];

  int get pendingCount =>
      where((assistant) => assistant.status == VanAssistantStatus.pending)
          .length;
}
