import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/personal_address.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/personal_address_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/repositories/personal_address_repository.dart';

class FindMyPersonalAddress {
  const FindMyPersonalAddress(this._repository);

  final PersonalAddressRepository _repository;

  Future<Result<PersonalAddressFailure, PersonalAddress?>> call() {
    return _repository.findMyAddress();
  }
}
