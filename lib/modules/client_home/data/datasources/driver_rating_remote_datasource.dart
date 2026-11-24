import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/driver_to_rate.dart';

class DriverRatingRemoteDataSource {
  const DriverRatingRemoteDataSource({
    required this.dio,
    required this.environment,
  });

  final Dio dio;
  final Environment environment;

  /// Drivers linked to the client, one entry per driver.
  Future<List<DriverToRate>> fetchMyDrivers() async {
    final response = await dio.get<List<dynamic>>(
      environment.clientDriversMeEndpoint,
    );
    final drivers = <String, DriverToRate>{};
    for (final link
        in (response.data ?? const []).whereType<Map<String, dynamic>>()) {
      final token = link['driverToken'];
      if (token is! String || token.isEmpty) continue;
      drivers[token] = DriverToRate(
        token: token,
        name: link['driverName'] as String? ?? '',
      );
    }
    return drivers.values.toList();
  }

  /// Whether the API accepts a rating from the client for this driver now: it
  /// requires a contract that reached active, a link old enough and no rating.
  Future<bool> canRate(String driverToken) async {
    final response = await dio.get<Map<String, dynamic>>(
      environment.driverRatingStatusEndpoint,
      queryParameters: {'driverToken': driverToken},
    );
    return response.data?['canRate'] == true;
  }

  Future<void> rate(String driverToken, int stars) {
    return dio.post<void>(
      environment.driverRatingsEndpoint,
      data: {'driverToken': driverToken, 'rating': stars},
    );
  }
}
