import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/assistant_remote_datasource.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/mocked_assistant_vans_datasource.dart';
import 'package:vanep_mobile/modules/assistant/data/repositories/assistant_repository_impl.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_vans_repository.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_vans_overview.dart';

class AssistantVansRepositoryImpl implements AssistantVansRepository {
  const AssistantVansRepositoryImpl({
    required this.remote,
    required this.dataSource,
  });

  /// Source of the pending invite.
  final AssistantRemoteDataSource remote;

  /// Source of the active vans and former links, still mocked.
  final AssistantVansDataSource dataSource;

  @override
  Future<Result<AssistantFailure, AssistantVansOverview>> findVansOverview() {
    return guardAssistantCall(() async {
      final invite = await remote.fetchPendingInvite();
      final vans = await dataSource.findVansOverview();
      return AssistantVansOverview(
        pendingInvite: invite,
        activeVans: vans.activeVans,
        formerVanCount: vans.formerVanCount,
      );
    });
  }
}
