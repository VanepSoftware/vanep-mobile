import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation.dart';
import 'package:vanep_mobile/modules/conversations/domain/failures/conversation_failure.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/find_conversation_negotiation.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/list_conversation_messages.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/open_conversation.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/send_conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/watch_conversation.dart';
import 'package:vanep_mobile/modules/conversations/domain/value_objects/conversation_negotiation.dart';
import 'package:vanep_mobile/modules/conversations/domain/value_objects/conversation_realtime_event.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required this.openConversation,
    required this.listConversationMessages,
    required this.sendConversationMessage,
    required this.watchConversation,
    required this.findConversationNegotiation,
    this.driverToken,
    Conversation? conversation,
  }) : assert(driverToken != null || conversation != null),
       super(ChatState(conversation: conversation));

  final OpenConversation openConversation;
  final ListConversationMessages listConversationMessages;
  final SendConversationMessage sendConversationMessage;
  final WatchConversation watchConversation;
  final FindConversationNegotiation findConversationNegotiation;
  final String? driverToken;

  StreamSubscription<ConversationRealtimeEvent>? realtimeSubscription;

  Future<void> start() async {
    emit(state.copyWith(status: ChatStatus.loading, clearFailure: true));
    final conversation =
        state.conversation ?? await openConversationWithDriver();
    if (conversation == null) return;
    final negotiationLoad = findConversationNegotiation(conversation.token);
    await loadLatestMessages();
    applyNegotiation(await negotiationLoad);
    if (state.isReady) watchConversationEvents(conversation);
  }

  void applyNegotiation(
    Result<ConversationFailure, ConversationNegotiation> result,
  ) {
    if (isClosed || !state.isReady) return;
    emit(
      result.fold(
        (failure) => state.copyWith(failure: failure),
        (negotiation) => state.copyWith(negotiation: negotiation),
      ),
    );
  }

  Future<Conversation?> openConversationWithDriver() async {
    final result = await openConversation(driverToken!);
    switch (result) {
      case Ok(:final value):
        emit(state.copyWith(conversation: value));
        return value;
      case Err(:final error):
        emit(state.copyWith(status: ChatStatus.loadFailed, failure: error));
        return null;
    }
  }

  Future<void> loadLatestMessages() async {
    final wasReady = state.isReady;
    final result = await listConversationMessages(
      conversationToken: state.conversation!.token,
      page: 0,
    );
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => wasReady
            ? state.copyWith(failure: failure)
            : state.copyWith(status: ChatStatus.loadFailed, failure: failure),
        (page) => state.copyWith(
          status: ChatStatus.ready,
          messages: mergeConversationMessages(state.messages, page.messages),
          hasMore: wasReady ? state.hasMore : page.hasMore,
          clearFailure: true,
        ),
      ),
    );
  }

  Future<void> loadOlderMessages() async {
    if (!state.isReady || !state.hasMore || state.isLoadingOlder) return;
    emit(state.copyWith(isLoadingOlder: true));
    final result = await listConversationMessages(
      conversationToken: state.conversation!.token,
      page: state.nextPage,
    );
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => state.copyWith(isLoadingOlder: false, failure: failure),
        (page) => state.copyWith(
          isLoadingOlder: false,
          messages: mergeConversationMessages(state.messages, page.messages),
          hasMore: page.hasMore,
          nextPage: state.nextPage + 1,
        ),
      ),
    );
  }

  Future<bool> sendMessage(String body) async {
    if (!state.isReady || state.isSending) return false;
    emit(state.copyWith(isSending: true, clearFailure: true));
    final result = await sendConversationMessage(
      conversationToken: state.conversation!.token,
      body: body,
    );
    if (isClosed) return result.isOk;
    emit(
      result.fold(
        (failure) => state.copyWith(isSending: false, failure: failure),
        (message) => state.copyWith(
          isSending: false,
          messages: mergeConversationMessages(state.messages, [message]),
        ),
      ),
    );
    return result.isOk;
  }

  void watchConversationEvents(Conversation conversation) {
    if (realtimeSubscription != null) return;
    realtimeSubscription = watchConversation(conversation.token)
        .listen(applyRealtimeEvent);
  }

  void applyRealtimeEvent(ConversationRealtimeEvent event) {
    switch (event) {
      case ConversationMessageReceived(:final message):
        emit(
          state.copyWith(
            messages: mergeConversationMessages(state.messages, [message]),
          ),
        );
      case ConversationRealtimeReconnected():
        unawaited(loadLatestMessages());
    }
  }

  @override
  Future<void> close() async {
    await realtimeSubscription?.cancel();
    return super.close();
  }
}
