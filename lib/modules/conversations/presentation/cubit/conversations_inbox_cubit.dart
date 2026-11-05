import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/modules/conversations/domain/usecases/list_my_conversations.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/conversations_inbox_state.dart';

class ConversationsInboxCubit extends Cubit<ConversationsInboxState> {
  ConversationsInboxCubit({required this.listMyConversations})
    : super(const ConversationsInboxState());

  final ListMyConversations listMyConversations;

  Future<void> loadConversations() async {
    if (state.status != ConversationsInboxStatus.ready) {
      emit(
        const ConversationsInboxState(status: ConversationsInboxStatus.loading),
      );
    }
    final result = await listMyConversations();
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => ConversationsInboxState(
          status: ConversationsInboxStatus.loadFailed,
          conversations: state.conversations,
          failure: failure,
        ),
        (conversations) => ConversationsInboxState(
          status: ConversationsInboxStatus.ready,
          conversations: conversations,
        ),
      ),
    );
  }
}
