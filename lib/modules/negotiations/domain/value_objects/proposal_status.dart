import 'package:vanep_mobile/modules/negotiations/domain/value_objects/api_name.dart';

enum ProposalStatus {
  sent('SENT'),
  accepted('ACCEPTED'),
  superseded('SUPERSEDED'),
  declined('DECLINED'),
  expired('EXPIRED'),
  withdrawn('WITHDRAWN');

  const ProposalStatus(this.apiName);

  final String apiName;

  static ProposalStatus? fromApi(Object? raw) {
    return findByApiName(values, (value) => value.apiName, raw);
  }

  static String? toApi(ProposalStatus? value) => value?.apiName;
}
