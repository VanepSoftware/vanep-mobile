import '../../../../core/result/result.dart';
import '../entities/personal_address.dart';
import '../failures/personal_address_failure.dart';
import '../repositories/personal_address_repository.dart';

class FindMyPersonalAddress {
  const FindMyPersonalAddress(this._repository);

  final PersonalAddressRepository _repository;

  Future<Result<PersonalAddressFailure, PersonalAddress?>> call() {
    return _repository.findMyAddress();
  }
}
