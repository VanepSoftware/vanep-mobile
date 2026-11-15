import 'package:vanep_mobile/modules/client_home/domain/value_objects/client_home.dart';

abstract class DailyOverviewDataSource {
  Future<DailyOverview> findDailyOverview();
}
