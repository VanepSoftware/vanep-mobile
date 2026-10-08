import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/personal_address_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/repositories/personal_address_repository.dart';

class DeleteMyPersonalAddress {
  const DeleteMyPersonalAddress(this._repository);

  final PersonalAddressRepository _repository;

  Future<Result<PersonalAddressFailure, void>> call() {
    return _repository.deleteMyAddress();
  }
}
