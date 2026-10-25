import 'package:vanep_mobile/core/domain/gender.dart';

abstract class Dependent {
  String get token;

  String get name;

  String? get birthDate;

  Gender? get gender;

  bool get isDefault;

  DependentAddress? get address;

  DependentSchool? get school;

  String? get document;
}

abstract class DependentSchool {
  String get token;

  String get name;

  DependentAddress? get address;
}

abstract class DependentAddress {
  String get token;

  String get street;

  String? get number;

  String? get complement;

  String? get zipCode;

  String? get neighborhood;

  String get cityToken;

  String get cityName;

  String get stateUf;
}
