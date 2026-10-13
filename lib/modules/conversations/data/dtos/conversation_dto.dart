import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:vanep_mobile/modules/conversations/domain/entities/conversation.dart';

part 'conversation_dto.freezed.dart';
part 'conversation_dto.g.dart';

@freezed
abstract class ConversationDto with _$ConversationDto implements Conversation {
  const factory ConversationDto({
    @Default('') String token,
    @Default('') String driverToken,
    @Default('') String driverName,
    @Default('') String clientName,
    DateTime? lastMessageAt,
  }) = _ConversationDto;

  factory ConversationDto.fromJson(Map<String, Object?> json) =>
      _$ConversationDtoFromJson(json);
}

List<Conversation> readConversations(List<dynamic>? payload) {
  if (payload == null) return const [];
  return payload
      .whereType<Map<String, dynamic>>()
      .map(
        (entry) => ConversationDto.fromJson(Map<String, Object?>.from(entry)),
      )
      .toList();
}

Conversation readConversation(Map<String, dynamic>? payload) {
  if (payload == null) {
    throw const FormatException('Empty conversation payload.');
  }
  return ConversationDto.fromJson(Map<String, Object?>.from(payload));
}
