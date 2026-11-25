import 'package:vanep_mobile/core/domain/schedule/api_name.dart';

enum RejectionReason {
  illegible('ILLEGIBLE'),
  expired('EXPIRED'),
  dataMismatch('DATA_MISMATCH'),
  wrongType('WRONG_TYPE'),
  incomplete('INCOMPLETE'),
  notEligible('NOT_ELIGIBLE'),
  other('OTHER');

  const RejectionReason(this.apiName);

  final String apiName;

  static RejectionReason? fromApi(Object? raw) =>
      findByApiName(values, (reason) => reason.apiName, raw);
}
