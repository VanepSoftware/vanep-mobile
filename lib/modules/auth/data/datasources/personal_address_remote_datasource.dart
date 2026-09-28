import 'package:dio/dio.dart';

import '../../../../core/environment/environment.dart';
import '../../domain/value_objects/personal_address_write.dart';
import '../dtos/personal_address_dto.dart';

class PersonalAddressRemoteDataSource {
  PersonalAddressRemoteDataSource({
    required this.dio,
    required this.environment,
  });

  final Dio dio;
  final Environment environment;

  Future<PersonalAddressDto> fetchMyAddress() async {
    final response = await dio.get<Map<String, dynamic>>(
      environment.userPersonalAddressEndpoint,
    );
    return PersonalAddressDto.fromJson(response.data!);
  }

  Future<PersonalAddressDto> upsertMyAddress(PersonalAddressWrite write) async {
    final response = await dio.put<Map<String, dynamic>>(
      environment.userPersonalAddressEndpoint,
      data: personalAddressUpsertBody(write),
    );
    return PersonalAddressDto.fromJson(response.data!);
  }

  Future<void> deleteMyAddress() async {
    await dio.delete<void>(environment.userPersonalAddressEndpoint);
  }
}
