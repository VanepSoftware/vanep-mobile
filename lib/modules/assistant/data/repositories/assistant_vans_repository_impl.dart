import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/mocked_assistant_vans_datasource.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_vans_repository.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_vans_overview.dart';

class AssistantVansRepositoryImpl implements AssistantVansRepository {
  const AssistantVansRepositoryImpl({required this.dataSource});

  final AssistantVansDataSource dataSource;

  @override
  Future<Result<AssistantFailure, AssistantVansOverview>>
  findVansOverview() async {
    return Ok(await dataSource.findVansOverview());
  }
}
