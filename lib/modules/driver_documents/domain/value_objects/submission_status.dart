import 'package:vanep_mobile/core/domain/schedule/api_name.dart';

enum SubmissionStatus {
  pending('PENDING'),
  approved('APPROVED'),
  rejected('REJECTED');

  const SubmissionStatus(this.apiName);

  final String apiName;

  static SubmissionStatus? fromApi(Object? raw) =>
      findByApiName(values, (status) => status.apiName, raw);
}
