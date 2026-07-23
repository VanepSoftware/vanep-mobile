import '../../auth/domain/value_objects/user_type.dart';

UserType? profileSummaryUserType(UserType? type) {
  return switch (type) {
    UserType.client || UserType.driver || UserType.assistant => type,
    UserType.admin || null => null,
  };
}

bool supportsProfileSummary(UserType? type) {
  return profileSummaryUserType(type) != null;
}
