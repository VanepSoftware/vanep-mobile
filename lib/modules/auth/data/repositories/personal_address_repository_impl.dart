import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/personal_address.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/personal_address_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/repositories/personal_address_repository.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/personal_address_write.dart';
import 'package:vanep_mobile/modules/auth/data/datasources/personal_address_remote_datasource.dart';
import 'package:vanep_mobile/modules/auth/data/dtos/personal_address_dto.dart';

bool isPersonalAddressAbsent(DioException exception) {
  return exception.response?.statusCode == 404;
}

PersonalAddressFailure personalAddressTransportFailureFrom(
  DioException exception,
) {
  if (exception.response?.statusCode == null) {
    return PersonalAddressFailure.network;
  }
  return PersonalAddressFailure.unexpected;
}

PersonalAddressFailure personalAddressUpsertFailureFrom(
  DioException exception,
) {
  final status = exception.response?.statusCode;
  if (status == null) return PersonalAddressFailure.network;
  if (status == 404) return PersonalAddressFailure.cityNotFound;
  if (status == 400) return PersonalAddressFailure.validation;
  return PersonalAddressFailure.unexpected;
}

class PersonalAddressRepositoryImpl implements PersonalAddressRepository {
  const PersonalAddressRepositoryImpl({required this.remote});

  final PersonalAddressRemoteDataSource remote;

  @override
  Future<Result<PersonalAddressFailure, PersonalAddress?>>
  findMyAddress() async {
    try {
      return Ok(personalAddressFromDto(await remote.fetchMyAddress()));
    } on DioException catch (exception) {
      if (isPersonalAddressAbsent(exception)) {
        return const Ok(null);
      }
      return Err(personalAddressTransportFailureFrom(exception));
    }
  }

  @override
  Future<Result<PersonalAddressFailure, PersonalAddress>> upsertMyAddress(
    PersonalAddressWrite write,
  ) async {
    try {
      return Ok(personalAddressFromDto(await remote.upsertMyAddress(write)));
    } on DioException catch (exception) {
      return Err(personalAddressUpsertFailureFrom(exception));
    }
  }

  @override
  Future<Result<PersonalAddressFailure, void>> deleteMyAddress() async {
    try {
      await remote.deleteMyAddress();
      return const Ok(null);
    } on DioException catch (exception) {
      return Err(personalAddressTransportFailureFrom(exception));
    }
  }
}
