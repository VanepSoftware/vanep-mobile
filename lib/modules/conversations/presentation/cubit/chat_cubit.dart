import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/modules/conversations/domain/usecases/list_conversation_messages.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/send_conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/watch_conversation.dart';
import 'package:vanep_mobile/modules/conversations/domain/value_objects/conversation_realtime_event.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required this.listConversationMessages,
    required this.sendConversationMessage,
    required this.watchConversation,
    required this.conversationToken,
  }) : super(const ChatState());

  final String conversationToken;
  final ListConversationMessages listConversationMessages;
  final SendConversationMessage sendConversationMessage;
  final WatchConversation watchConversation;

  StreamSubscription<ConversationRealtimeEvent>? realtimeSubscription;

  Future<void> start() async {
    emit(state.copyWith(status: ChatStatus.loading, clearFailure: true));
    await loadLatestMessages();
    if (state.isReady) watchConversationEvents();
  }

  Future<void> loadLatestMessages() async {
    final wasReady = state.isReady;
    final result = await listConversationMessages(
      conversationToken: conversationToken,
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
      conversationToken: conversationToken,
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
      conversationToken: conversationToken,
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

  void watchConversationEvents() {
    if (realtimeSubscription != null) return;
    realtimeSubscription = watchConversation(conversationToken)
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
