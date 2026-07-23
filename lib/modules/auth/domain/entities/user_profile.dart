import '../value_objects/user_type.dart';

abstract class UserProfile {
  String get token;

  String? get name;

  String? get email;

  UserType? get type;
}
