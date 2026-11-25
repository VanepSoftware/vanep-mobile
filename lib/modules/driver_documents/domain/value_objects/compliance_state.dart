import 'package:vanep_mobile/core/domain/schedule/api_name.dart';

enum ComplianceState {
  missing('MISSING'),
  pending('PENDING'),
  approved('APPROVED'),
  rejected('REJECTED'),
  expired('EXPIRED');

  const ComplianceState(this.apiName);

  final String apiName;

  static ComplianceState? fromApi(Object? raw) =>
      findByApiName(values, (state) => state.apiName, raw);
}
