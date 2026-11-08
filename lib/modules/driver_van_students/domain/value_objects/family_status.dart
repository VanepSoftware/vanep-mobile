import 'package:vanep_mobile/core/domain/schedule/api_name.dart';

enum FamilyStatus {
  notInvited('NOT_INVITED'),
  invited('INVITED'),
  familyJoined('FAMILY_JOINED'),
  withFamily('WITH_FAMILY');

  const FamilyStatus(this.apiName);

  final String apiName;

  bool get hasFamily => this == FamilyStatus.withFamily;

  static FamilyStatus? fromApi(Object? raw) {
    return findByApiName(values, (value) => value.apiName, raw);
  }
}
