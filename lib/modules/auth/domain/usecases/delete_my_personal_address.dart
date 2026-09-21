import '../../../../core/result/result.dart';
import '../failures/personal_address_failure.dart';
import '../repositories/personal_address_repository.dart';

class DeleteMyPersonalAddress {
  const DeleteMyPersonalAddress(this._repository);

  final PersonalAddressRepository _repository;

  Future<Result<PersonalAddressFailure, void>> call() {
    return _repository.deleteMyAddress();
  }
}
