import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/client_home/data/datasources/daily_overview_datasource.dart';
import 'package:vanep_mobile/modules/client_home/domain/failures/client_home_failure.dart';
import 'package:vanep_mobile/modules/client_home/domain/repositories/client_home_repository.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/client_home.dart';

class ClientHomeRepositoryImpl implements ClientHomeRepository {
  const ClientHomeRepositoryImpl({required this.dataSource});

  final DailyOverviewDataSource dataSource;

  @override
  Future<Result<ClientHomeFailure, DailyOverview>> findDailyOverview() async {
    try {
      return Ok(await dataSource.findDailyOverview());
    } on Object {
      return const Err(ClientHomeFailure.unexpected);
    }
  }
}
