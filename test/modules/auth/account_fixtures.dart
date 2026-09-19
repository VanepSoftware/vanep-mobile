import 'package:vanep_mobile/core/domain/gender.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/signup_form.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';

const validCpf = '529.982.247-25';

final validClientSignupForm = SignupForm(
  type: UserType.client,
  name: 'Ana Cliente',
  email: 'ana@vanep.com.br',
  password: 'secret1',
  document: validCpf,
  phone: '(11) 99999-0000',
  birthDate: DateTime(1990, 5, 15),
  gender: Gender.female,
  acceptTerms: true,
);

final validDriverSignupForm = validClientSignupForm.copyWith(
  type: UserType.driver,
  basePrice: '1.250,50',
  cnpj: '11.222.333/0001-81',
  experienceYears: '7',
);
