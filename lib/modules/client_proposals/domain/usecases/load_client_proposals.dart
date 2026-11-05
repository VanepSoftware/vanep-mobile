import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/failures/client_proposals_failure.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/repositories/client_proposals_repository.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/client_proposals.dart';

class LoadClientProposals {
  const LoadClientProposals({
    required this.repository,
    this.clock = DateTime.now,
  });

  final ClientProposalsRepository repository;

  final DateTime Function() clock;

  Future<Result<ClientProposalsFailure, ClientProposals>> call() async {
    final (feedResult, childrenResult) = await (
      repository.findProposals(),
      repository.findChildren(),
    ).wait;

    final failure = feedResult.errorOrNull ?? childrenResult.errorOrNull;
    if (failure != null) return Err(failure);

    return Ok(
      ClientProposals(
        loadedAt: clock(),
        children: childrenResult.valueOrNull!,
        feed: feedResult.valueOrNull!,
      ),
    );
  }
}
