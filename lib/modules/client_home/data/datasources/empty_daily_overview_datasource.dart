import 'package:vanep_mobile/modules/client_home/data/datasources/daily_overview_datasource.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/client_home.dart';

// TODO(VAN-41): replace with a remote data source once the API serves the
// daily route, proposals, contracts and payments of the client.
class EmptyDailyOverviewDataSource implements DailyOverviewDataSource {
  const EmptyDailyOverviewDataSource();

  @override
  Future<DailyOverview> findDailyOverview() async => const DailyOverview();
}
