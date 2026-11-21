import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/find_assistant_former_links.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_former_link.dart';

enum AssistantFormerLinksStatus { loading, ready, loadFailed }

class AssistantFormerLinksState extends Equatable {
  const AssistantFormerLinksState({
    this.status = AssistantFormerLinksStatus.loading,
    this.links = const [],
    this.failure,
  });

  final AssistantFormerLinksStatus status;
  final List<AssistantFormerLink> links;
  final AssistantFailure? failure;

  @override
  List<Object?> get props => [status, links, failure];
}

class AssistantFormerLinksCubit extends Cubit<AssistantFormerLinksState> {
  AssistantFormerLinksCubit({required this.findFormerLinks})
    : super(const AssistantFormerLinksState());

  final FindAssistantFormerLinks findFormerLinks;

  Future<void> loadFormerLinks() async {
    emit(const AssistantFormerLinksState());
    final result = await findFormerLinks();
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => AssistantFormerLinksState(
          status: AssistantFormerLinksStatus.loadFailed,
          failure: failure,
        ),
        (links) => AssistantFormerLinksState(
          status: AssistantFormerLinksStatus.ready,
          links: latestEndedFirst(links),
        ),
      ),
    );
  }
}
