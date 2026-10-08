import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/personal_address.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/personal_address_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/personal_address_write.dart';

abstract class PersonalAddressRepository {
  Future<Result<PersonalAddressFailure, PersonalAddress?>> findMyAddress();

  Future<Result<PersonalAddressFailure, PersonalAddress>> upsertMyAddress(
    PersonalAddressWrite write,
  );

  Future<Result<PersonalAddressFailure, void>> deleteMyAddress();
}
