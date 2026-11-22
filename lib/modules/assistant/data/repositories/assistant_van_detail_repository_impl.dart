import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/mocked_assistant_van_detail_datasource.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_van_detail_repository.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_van_detail.dart';

class AssistantVanDetailRepositoryImpl implements AssistantVanDetailRepository {
  const AssistantVanDetailRepositoryImpl({required this.dataSource});

  final AssistantVanDetailDataSource dataSource;

  @override
  Future<Result<AssistantFailure, AssistantVanDetail>> findVanDetail(
    String vanToken,
  ) async {
    return Ok(await dataSource.findVanDetail(vanToken));
  }

  @override
  Future<Result<AssistantFailure, void>> leaveVan(String vanToken) async {
    await dataSource.leaveVan(vanToken);
    return const Ok(null);
  }
}
