import '../value_objects/gender.dart';
import '../value_objects/user_type.dart';

abstract class UserProfile {
  String get token;

  String? get name;

  String? get email;

  String? get phone;

  String? get document;

  String? get birthDate;

  Gender? get gender;

  UserType? get type;
}
