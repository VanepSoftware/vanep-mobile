import '../../../../core/result/result.dart';
import '../entities/personal_address.dart';
import '../failures/personal_address_failure.dart';
import '../value_objects/personal_address_write.dart';

abstract class PersonalAddressRepository {
  Future<Result<PersonalAddressFailure, PersonalAddress?>> findMyAddress();

  Future<Result<PersonalAddressFailure, PersonalAddress>> upsertMyAddress(
    PersonalAddressWrite write,
  );

  Future<Result<PersonalAddressFailure, void>> deleteMyAddress();
}
