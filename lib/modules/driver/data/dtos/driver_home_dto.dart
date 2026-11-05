import 'package:vanep_mobile/modules/driver/domain/entities/driver_home_data.dart';

class DriverOnboardingDto {
  const DriverOnboardingDto({
    required this.registration,
    required this.expiredDocument,
    required this.subscriptionBlocked,
    this.rejectionReason,
  });

  factory DriverOnboardingDto.fromJson(Map<String, Object?> json) {
    final cnhStep = json['cnhStep'];
    final pendingCnh = cnhStep is Map
        ? (cnhStep['pendingItems'] as List<dynamic>? ?? const [])
        : const <dynamic>[];
    final expiredCnh = pendingCnh.any(
      (item) => item.toString().toLowerCase() == 'cnh_expired',
    );

    final rawReason = json['rejectionReason'];
    final rejectionReason =
        rawReason is String && rawReason.trim().isNotEmpty
            ? rawReason.trim()
            : null;

    return DriverOnboardingDto(
      registration: RegistrationStatus.fromApi(json['approvalStatus']),
      expiredDocument: expiredCnh || json['expiredDocument'] == true,
      subscriptionBlocked: json['subscriptionBlocked'] == true,
      rejectionReason: rejectionReason,
    );
  }

  final RegistrationStatus registration;
  final bool expiredDocument;
  final bool subscriptionBlocked;
  final String? rejectionReason;
}

class DriverTripDto {
  const DriverTripDto({
    required this.token,
    required this.shift,
    required this.status,
    required this.outsideWorkWindow,
  });

  factory DriverTripDto.fromJson(Map<String, Object?> json) {
    final shift = (json['shift'] as String? ?? 'MORNING').trim().toUpperCase();
    return DriverTripDto(
      token: (json['token'] as String? ?? shift).trim(),
      shift: shift,
      status: TripStatus.fromApi(json['status']),
      outsideWorkWindow: json['outsideWorkWindow'] == true,
    );
  }

  final String token;
  final String shift;
  final TripStatus? status;
  final bool outsideWorkWindow;

  int get shiftOrder => switch (shift) {
    'MORNING' => 0,
    'AFTERNOON' => 1,
    'NIGHT' => 2,
    'FULLTIME' => 3,
    _ => 4,
  };

  String get shiftLabel => switch (shift) {
    'MORNING' => 'Manhã',
    'AFTERNOON' => 'Tarde',
    'NIGHT' => 'Noite',
    'FULLTIME' => 'Integral',
    _ => shift,
  };

  Trip? toDomain() {
    final domainStatus = status;
    if (domainStatus == null) return null;
    return Trip(
      id: token,
      status: domainStatus,
      label: shiftLabel,
      shift: shift,
    );
  }
}

class DriverHomeDto {
  const DriverHomeDto._();

  static DriverHomeData compose({
    required DriverOnboardingDto onboarding,
    List<DriverTripDto> trips = const [],
    List<Map<String, Object?>> clientLinks = const [],
  }) {
    final validTrips = trips.where((t) => t.status != null).toList()
      ..sort((a, b) => a.shiftOrder.compareTo(b.shiftOrder));

    DriverTripDto? selectedDto;
    String? laterShiftLabel;

    final inProgress = validTrips
        .where((t) => t.status == TripStatus.inProgress)
        .firstOrNull;
    final scheduled = validTrips
        .where((t) => t.status == TripStatus.notStarted)
        .firstOrNull;
    final completedList = validTrips
        .where((t) => t.status == TripStatus.completed)
        .toList();

    if (inProgress != null) {
      selectedDto = inProgress;
    } else if (completedList.isNotEmpty && scheduled != null) {
      final lastCompleted = completedList.last;
      if (scheduled.shiftOrder > lastCompleted.shiftOrder) {
        selectedDto = lastCompleted;
        laterShiftLabel = scheduled.shiftLabel;
      } else {
        selectedDto = scheduled;
      }
    } else if (scheduled != null) {
      selectedDto = scheduled;
    } else if (completedList.isNotEmpty) {
      selectedDto = completedList.last;
    }

    final activeStudents = clientLinks.where((link) {
      final status = (link['status'] as String? ?? '').trim().toUpperCase();
      return status == 'ACTIVE';
    }).length;

    return DriverHomeData(
      registration: onboarding.registration,
      subscriptionBlocked: onboarding.subscriptionBlocked,
      expiredDocument: onboarding.expiredDocument,
      rejectionReason: onboarding.rejectionReason,
      todayTrip: selectedDto?.toDomain(),
      laterShiftLabel: laterShiftLabel,
      studentCount: activeStudents,
      familiesInApp: activeStudents,
      outsideWorkingHours: selectedDto?.outsideWorkWindow ?? false,
    );
  }
}
