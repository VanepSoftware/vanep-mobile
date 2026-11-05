import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:vanep_mobile/core/network/paging_json.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';

part 'conversation_message_dto.freezed.dart';
part 'conversation_message_dto.g.dart';

ConversationParticipant conversationParticipantFromApi(String value) =>
    switch (value) {
      'CLIENT' => ConversationParticipant.client,
      'DRIVER' => ConversationParticipant.driver,
      _ => throw FormatException('Unknown conversation participant: $value'),
    };

String conversationParticipantToApi(ConversationParticipant participant) =>
    participant.name.toUpperCase();

@freezed
abstract class ConversationMessageDto
    with _$ConversationMessageDto
    implements ConversationMessage {
  const factory ConversationMessageDto({
    @Default('') String token,
    @Default('') String body,
    @JsonKey(
      fromJson: conversationParticipantFromApi,
      toJson: conversationParticipantToApi,
    )
    required ConversationParticipant sender,
    required DateTime sentAt,
  }) = _ConversationMessageDto;

  factory ConversationMessageDto.fromJson(Map<String, Object?> json) =>
      _$ConversationMessageDtoFromJson(json);
}

ConversationMessage readConversationMessage(Map<String, dynamic>? payload) {
  if (payload == null) {
    throw const FormatException('Empty conversation message payload.');
  }
  return ConversationMessageDto.fromJson(Map<String, Object?>.from(payload));
}

ConversationMessagePage readConversationMessagePage(Map<String, dynamic> json) {
  final content = json['content'];
  final messages = content is List
      ? content
            .whereType<Map<String, dynamic>>()
            .map(readConversationMessage)
            .toList()
      : const <ConversationMessage>[];
  final pageNumber = readPagingInt(json['number']);
  final totalPages = readPagingInt(json['totalPages']);
  return ConversationMessagePage(
    messages: messages,
    hasMore: pageNumber + 1 < totalPages,
  );
}

// A frame that is not a message is dropped: the REST history stays the source of truth.
ConversationMessage? tryReadConversationMessageFrame(String? body) {
  if (body == null) return null;
  try {
    final json = jsonDecode(body);
    return json is Map<String, dynamic> ? readConversationMessage(json) : null;
  } on FormatException {
    return null;
  } on TypeError {
    return null;
  }
}
