import 'package:equatable/equatable.dart';

class AssistantVan extends Equatable {
  const AssistantVan({
    required this.token,
    required this.driverToken,
    required this.driverName,
    required this.plate,
    required this.model,
    this.shift,
  });

  final String token;

  final String driverToken;

  final String driverName;

  final String plate;

  final String model;

  final String? shift;

  @override
  List<Object?> get props => [
    token,
    driverToken,
    driverName,
    plate,
    model,
    shift,
  ];
}
