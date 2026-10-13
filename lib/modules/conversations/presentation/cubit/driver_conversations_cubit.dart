import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/modules/conversations/domain/usecases/list_driver_conversations.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/driver_conversations_state.dart';

class DriverConversationsCubit extends Cubit<DriverConversationsState> {
  DriverConversationsCubit({required this.listDriverConversations})
    : super(const DriverConversationsState());

  final ListDriverConversations listDriverConversations;

  Future<void> loadConversations() async {
    if (state.status != DriverConversationsStatus.ready) {
      emit(
        const DriverConversationsState(
          status: DriverConversationsStatus.loading,
        ),
      );
    }
    final result = await listDriverConversations();
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => DriverConversationsState(
          status: DriverConversationsStatus.loadFailed,
          conversations: state.conversations,
          failure: failure,
        ),
        (conversations) => DriverConversationsState(
          status: DriverConversationsStatus.ready,
          conversations: conversations,
        ),
      ),
    );
  }
}
