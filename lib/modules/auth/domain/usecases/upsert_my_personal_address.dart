import '../../../../core/result/result.dart';
import '../entities/personal_address.dart';
import '../failures/personal_address_failure.dart';
import '../repositories/personal_address_repository.dart';
import '../value_objects/personal_address_write.dart';

class UpsertMyPersonalAddress {
  const UpsertMyPersonalAddress(this._repository);

  final PersonalAddressRepository _repository;

  Future<Result<PersonalAddressFailure, PersonalAddress>> call(
    PersonalAddressWrite write,
  ) {
    return _repository.upsertMyAddress(write);
  }
}
