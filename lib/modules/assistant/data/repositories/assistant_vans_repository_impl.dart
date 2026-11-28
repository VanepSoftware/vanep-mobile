import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/assistant_remote_datasource.dart';
import 'package:vanep_mobile/modules/assistant/data/repositories/assistant_repository_impl.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_vans_repository.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_vans_overview.dart';

class AssistantVansRepositoryImpl implements AssistantVansRepository {
  const AssistantVansRepositoryImpl({required this.remote});

  final AssistantRemoteDataSource remote;

  /// Pending invite, active vans and former links, fetched together from
  /// /api/assistants/me/invite, /me/vans and /me.
  @override
  Future<Result<AssistantFailure, AssistantVansOverview>> findVansOverview() {
    return guardAssistantCall(() async {
      final (invite, vans, formerLinks) = await (
        remote.fetchPendingInvite(),
        remote.fetchVanSummaries(),
        remote.fetchFormerLinkCount(),
      ).wait;
      return AssistantVansOverview(
        pendingInvite: invite,
        activeVans: vans,
        formerVanCount: formerLinks,
      );
    });
  }
}
