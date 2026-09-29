import 'package:vanep_mobile/core/domain/gender.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';

class TestDependent implements Dependent {
  const TestDependent({
    required this.token,
    required this.name,
    this.birthDate,
    this.gender,
    this.isDefault = false,
    this.address,
  });

  @override
  final String token;

  @override
  final String name;

  @override
  final String? birthDate;

  @override
  final Gender? gender;

  @override
  final bool isDefault;

  @override
  final DependentAddress? address;
}

class TestDependentAddress implements DependentAddress {
  const TestDependentAddress({
    this.token = 'address-1',
    this.street = 'QNL 5 Conjunto A',
    this.number = '12',
    this.complement,
    this.zipCode = '72120120',
    this.neighborhood = 'Taguatinga',
    this.cityToken = 'city-brasilia',
    this.cityName = 'Brasília',
    this.stateUf = 'DF',
  });

  @override
  final String token;

  @override
  final String street;

  @override
  final String? number;

  @override
  final String? complement;

  @override
  final String? zipCode;

  @override
  final String? neighborhood;

  @override
  final String cityToken;

  @override
  final String cityName;

  @override
  final String stateUf;
}

const testHelenaDependent = TestDependent(
  token: 'dep-helena',
  name: 'Helena Souza',
  birthDate: '2015-03-22',
  gender: Gender.female,
  isDefault: true,
);

const testMiguelDependent = TestDependent(
  token: 'dep-miguel',
  name: 'Miguel Souza',
  birthDate: '2018-11-04',
  gender: Gender.male,
);

const testDependentWithoutBirthDate = TestDependent(
  token: 'dep-sem-nascimento',
  name: 'Ana Souza',
);
