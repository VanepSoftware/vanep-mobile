import 'package:vanep_mobile/modules/negotiations/domain/value_objects/api_name.dart';

enum ProposalAdjustmentPolicy {
  none('NONE'),
  ipcaAtRenewal('IPCA_AT_RENEWAL');

  const ProposalAdjustmentPolicy(this.apiName);

  final String apiName;

  static ProposalAdjustmentPolicy? fromApi(Object? raw) {
    return findByApiName(values, (value) => value.apiName, raw);
  }

  static String? toApi(ProposalAdjustmentPolicy? value) => value?.apiName;
}
