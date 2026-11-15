import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/client_home/domain/failures/client_home_failure.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/client_home.dart';

abstract class ClientHomeRepository {
  Future<Result<ClientHomeFailure, DailyOverview>> findDailyOverview();
}
