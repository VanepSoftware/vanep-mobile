import 'package:vanep_mobile/core/domain/schedule/api_name.dart';

enum StudentSource {
  contractItem('CONTRACT_ITEM'),
  unlinkedPassenger('UNLINKED_PASSENGER');

  const StudentSource(this.apiName);

  final String apiName;

  static StudentSource? fromApi(Object? raw) {
    return findByApiName(values, (value) => value.apiName, raw);
  }
}
