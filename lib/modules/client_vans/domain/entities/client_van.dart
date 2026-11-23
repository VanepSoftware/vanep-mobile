import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/core/domain/school_shift.dart';

class ClientVanDriver extends Equatable {
  const ClientVanDriver({
    required this.token,
    required this.name,
    this.phone,
    this.photoUrl,
    this.rating,
  });

  final String token;
  final String name;
  final String? phone;
  final String? photoUrl;
  final double? rating;

  @override
  List<Object?> get props => [token, name, phone, photoUrl, rating];
}

class ClientVanVehicle extends Equatable {
  const ClientVanVehicle({
    required this.token,
    required this.brand,
    required this.model,
    this.manufactureYear,
    this.color,
    this.capacity,
    this.plate,
    this.photoFrontUrl,
    this.photoSideUrl,
  });

  final String token;
  final String brand;
  final String model;
  final int? manufactureYear;
  final String? color;
  final int? capacity;
  final String? plate;
  final String? photoFrontUrl;
  final String? photoSideUrl;

  String get displayName =>
      [brand, model].where((s) => s.trim().isNotEmpty).join(' ');

  @override
  List<Object?> get props => [
    token,
    brand,
    model,
    manufactureYear,
    color,
    capacity,
    plate,
    photoFrontUrl,
    photoSideUrl,
  ];
}

class ClientVanContract extends Equatable {
  const ClientVanContract({
    required this.token,
    required this.status,
    this.startsOn,
    this.endsOn,
    this.totalAmount,
    this.installments,
    this.installmentAmount,
    this.dueDay,
  });

  final String token;
  final String status;
  final DateTime? startsOn;
  final DateTime? endsOn;
  final double? totalAmount;
  final int? installments;
  final double? installmentAmount;
  final int? dueDay;

  @override
  List<Object?> get props => [
    token,
    status,
    startsOn,
    endsOn,
    totalAmount,
    installments,
    installmentAmount,
    dueDay,
  ];
}

class ClientVanDependent extends Equatable {
  const ClientVanDependent({
    required this.token,
    required this.name,
    required this.schoolName,
    required this.pickupAddress,
    this.shift,
    this.pickupTime,
    this.returnTime,
    this.weekdays = const ['Seg', 'Ter', 'Qua', 'Qui', 'Sex'],
  });

  final String token;
  final String name;
  final String schoolName;
  final String pickupAddress;
  final SchoolShift? shift;
  final String? pickupTime;
  final String? returnTime;
  final List<String> weekdays;

  @override
  List<Object?> get props => [
    token,
    name,
    schoolName,
    pickupAddress,
    shift,
    pickupTime,
    returnTime,
    weekdays,
  ];
}

class ClientVan extends Equatable {
  const ClientVan({
    required this.token,
    required this.status,
    required this.driver,
    this.vehicle,
    this.contract,
    this.dependents = const [],
  });

  final String token;
  final String status;
  final ClientVanDriver driver;
  final ClientVanVehicle? vehicle;
  final ClientVanContract? contract;
  final List<ClientVanDependent> dependents;

  bool get isActive =>
      status.toUpperCase() == 'ACTIVE' || status.toUpperCase() == 'ATIVA';

  @override
  List<Object?> get props => [
    token,
    status,
    driver,
    vehicle,
    contract,
    dependents,
  ];
}
