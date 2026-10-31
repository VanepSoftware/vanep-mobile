import 'package:vanep_mobile/modules/negotiations/domain/value_objects/api_name.dart';

enum ProposalAdjustmentField {
  price('PRICE'),
  installments('INSTALLMENTS'),
  schedule('SCHEDULE'),
  period('PERIOD'),
  other('OTHER');

  const ProposalAdjustmentField(this.apiName);

  final String apiName;

  static ProposalAdjustmentField? fromApi(Object? raw) {
    return findByApiName(values, (value) => value.apiName, raw);
  }

  static String? toApi(ProposalAdjustmentField? value) => value?.apiName;
}
