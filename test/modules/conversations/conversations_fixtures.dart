import 'package:vanep_mobile/core/domain/calendar_days.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/domain/value_objects/conversation_negotiation.dart';

class TestConversation implements Conversation {
  const TestConversation({
    this.token = 'conversation-1',
    this.driverToken = 'driver-1',
    this.driverName = 'Carlos Motorista',
    this.clientName = 'Ana Cliente',
    this.lastMessageAt,
  });

  @override
  final String token;

  @override
  final String driverToken;

  @override
  final String driverName;

  @override
  final String clientName;

  @override
  final DateTime? lastMessageAt;
}

class TestConversationMessage implements ConversationMessage {
  const TestConversationMessage({
    required this.token,
    required this.body,
    required this.sender,
    required this.sentAt,
  });

  @override
  final String token;

  @override
  final String body;

  @override
  final ConversationParticipant sender;

  @override
  final DateTime sentAt;
}

const testConversation = TestConversation();

final testClientMessage = TestConversationMessage(
  token: 'message-1',
  body: 'Tem vaga para a manhã?',
  sender: ConversationParticipant.client,
  sentAt: DateTime.utc(2026, 10, 12, 9),
);

final testDriverMessage = TestConversationMessage(
  token: 'message-2',
  body: 'Tenho sim, saio às 6h30.',
  sender: ConversationParticipant.driver,
  sentAt: DateTime.utc(2026, 10, 12, 9, 5),
);

final quoteRequest = QuoteRequestEvent(
  token: 'request-1',
  author: ConversationParticipant.client,
  occurredAt: DateTime(2026, 10, 10, 20, 14),
  childName: 'Pedro',
  childAge: 11,
  schoolName: 'Colégio Delta',
  shift: SchoolShift.afternoon,
  weekdays: weekdaysMondayToFriday,
  oneWayWeekdays: const [DateTime.wednesday],
  startsOn: DateTime(2027, 2),
  boardingPlace: 'QNL 5, Taguatinga',
);

ProposalVersionEvent proposalVersion({
  required int version,
  required DateTime occurredAt,
  int monthlyFeeCents = 30000,
  ConversationParticipant author = ConversationParticipant.driver,
}) {
  return ProposalVersionEvent(
    token: 'proposal-$version',
    author: author,
    occurredAt: occurredAt,
    version: version,
    monthlyFeeCents: monthlyFeeCents,
    installments: 12,
    dueDay: 10,
    startsOn: DateTime(2027, 2),
    endsOn: DateTime(2027, 12, 17),
    expiresAt: DateTime(2026, 10, 21),
    vehicleModel: 'Master',
    vehicleYear: 2019,
  );
}

final firstProposal = proposalVersion(
  version: 1,
  occurredAt: DateTime(2026, 10, 11, 10),
  monthlyFeeCents: 34000,
);

final adjustmentRequest = AdjustmentRequestEvent(
  token: 'adjustment-1',
  author: ConversationParticipant.client,
  occurredAt: DateTime(2026, 10, 12, 9, 40),
  suggestedMonthlyFeeCents: 29000,
  note: 'Tem como melhorar o valor? São 4 voltas por semana.',
);

final secondProposal = proposalVersion(
  version: 2,
  occurredAt: DateTime(2026, 10, 13, 11),
);

final fullNegotiation = ConversationNegotiation(
  events: [secondProposal, quoteRequest, adjustmentRequest, firstProposal],
);

final requestOnlyNegotiation = ConversationNegotiation(events: [quoteRequest]);

TestConversationMessage localMessage(
  String token,
  ConversationParticipant sender,
  DateTime sentAt,
) {
  return TestConversationMessage(
    token: token,
    body: 'Mensagem $token',
    sender: sender,
    sentAt: sentAt,
  );
}
