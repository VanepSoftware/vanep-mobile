import 'package:dio/dio.dart';

import '../../../../core/environment/environment.dart';
import '../../domain/entities/brazilian_city.dart';
import '../../domain/entities/brazilian_state.dart';
import '../../domain/entities/cep_lookup.dart';
import '../../domain/entities/ibge_locations_page.dart';
import '../dtos/brazilian_city_dto.dart';
import '../dtos/brazilian_state_dto.dart';
import '../dtos/cep_lookup_dto.dart';
import '../dtos/ibge_locations_page_dto.dart';

class IbgeLocationsRemoteDataSource {
  IbgeLocationsRemoteDataSource({required this.dio, required this.environment});

  final Dio dio;
  final Environment environment;

  Future<CepLookup> lookupCep(String cep) async {
    final response = await dio.get<Map<String, dynamic>>(
      environment.cepLookupEndpoint(cep),
    );
    return cepLookupFromJson(Map<String, Object?>.from(response.data!));
  }

  Future<IbgeLocationsPage<BrazilianState>> listStates({
    required int page,
    required int size,
  }) async {
    final response = await dio.get<Map<String, dynamic>>(
      environment.statesEndpoint,
      queryParameters: {'page': page, 'size': size},
    );
    return ibgeLocationsPageFromJson(
      Map<String, Object?>.from(response.data!),
      brazilianStateFromJson,
    );
  }

  Future<IbgeLocationsPage<BrazilianCity>> listCities({
    required String uf,
    String? search,
    required int page,
    required int size,
  }) async {
    final response = await dio.get<Map<String, dynamic>>(
      environment.citiesEndpoint,
      queryParameters: {
        'uf': uf,
        'page': page,
        'size': size,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    return ibgeLocationsPageFromJson(
      Map<String, Object?>.from(response.data!),
      brazilianCityFromJson,
    );
  }
}
