import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/personal_address.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/personal_address_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/repositories/personal_address_repository.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/personal_address_write.dart';

class UpsertMyPersonalAddress {
  const UpsertMyPersonalAddress(this._repository);

  final PersonalAddressRepository _repository;

  Future<Result<PersonalAddressFailure, PersonalAddress>> call(
    PersonalAddressWrite write,
  ) {
    return _repository.upsertMyAddress(write);
  }
}
