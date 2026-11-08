import 'package:vanep_mobile/modules/negotiations/domain/value_objects/api_name.dart';

enum ProposalCancellationPolicy {
  notice30Days('NOTICE_30_DAYS'),
  notice30DaysWithFee('NOTICE_30_DAYS_WITH_FEE');

  const ProposalCancellationPolicy(this.apiName);

  final String apiName;

  static ProposalCancellationPolicy? fromApi(Object? raw) {
    return findByApiName(values, (value) => value.apiName, raw);
  }

  static String? toApi(ProposalCancellationPolicy? value) => value?.apiName;
}
