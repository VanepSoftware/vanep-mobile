import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/modules/driver/domain/entities/driver_home_data.dart';
import 'package:vanep_mobile/modules/driver/data/dtos/driver_home_dto.dart';

class DriverHomeRemoteDataSource {
  DriverHomeRemoteDataSource({required this.dio, required this.environment});

  final Dio dio;
  final Environment environment;
  final Map<String, String> _shiftByTripId = {};

  Future<DriverHomeData> fetchHomeData() async {
    final onboardingResponse = await dio.get<Map<String, dynamic>>(
      environment.driverOnboardingEndpoint,
    );
    final onboardingJson = Map<String, Object?>.from(
      onboardingResponse.data ?? const {},
    );
    final onboarding = DriverOnboardingDto.fromJson(onboardingJson);

    if (onboarding.registration != RegistrationStatus.approved) {
      return DriverHomeDto.compose(onboarding: onboarding);
    }

    final results = await Future.wait<Object?>([
      _fetchTodayTripsSafe(),
      _fetchClientLinksSafe(),
      _fetchOccupancyOrNull(),
    ]);

    final trips = results[0] as List<DriverTripDto>;
    final clientLinks = results[1] as List<Map<String, Object?>>;
    final occupancy = results[2] as DriverStudentsCount?;

    _shiftByTripId
      ..clear()
      ..addEntries(trips.map((t) => MapEntry(t.token, t.shift)));

    return DriverHomeDto.compose(
      onboarding: onboarding,
      trips: trips,
      clientLinks: clientLinks,
      occupancy: occupancy,
    );
  }

  Future<void> startTrip(String tripId) async {
    final shift = _resolveShift(tripId);
    await dio.post<Map<String, dynamic>>(
      environment.driverTripsStartEndpoint,
      data: {'shift': shift},
    );
  }

  Future<void> confirmStop(StopConfirmation confirmation) async {
    // TODO(VAN-66): Replace this guard when the backend exposes stop confirmation.
    // DriverTripController currently supports only today, start and finish.
    throw UnsupportedError('Stop confirmation is not supported by the API');
  }

  Future<List<DriverTripDto>> _fetchTodayTripsSafe() async {
    final response = await dio.get<List<dynamic>>(
      environment.driverTripsTodayEndpoint,
    );
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((json) => DriverTripDto.fromJson(Map<String, Object?>.from(json)))
        .toList();
  }

  Future<List<Map<String, Object?>>> _fetchClientLinksSafe() async {
    final response = await dio.get<List<dynamic>>(
      environment.clientDriversMeEndpoint,
    );
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Map<String, Object?>.from)
        .toList();
  }

  /// The driver's student totals, or null when they cannot be read: the family
  /// counter is then left out instead of breaking the home.
  Future<DriverStudentsCount?> _fetchOccupancyOrNull() async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        environment.driverOccupancyEndpoint,
      );
      return driverStudentsCountFromJson(response.data);
    } on DioException {
      return null;
    }
  }

  String _resolveShift(String tripId) {
    final cached = _shiftByTripId[tripId];
    if (cached != null &&
        const {'MORNING', 'AFTERNOON', 'NIGHT', 'FULLTIME'}.contains(cached)) {
      return cached;
    }
    throw StateError('Cannot resolve shift for trip $tripId');
  }
}
