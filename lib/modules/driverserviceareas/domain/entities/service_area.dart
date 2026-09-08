import 'package:equatable/equatable.dart';

class ServiceArea extends Equatable {
  const ServiceArea({
    required this.token,
    required this.name,
    required this.cityName,
    required this.stateUf,
    required this.coversWholeCity,
  });

  final String token;

  final String name;

  final String cityName;

  final String stateUf;

  final bool coversWholeCity;

  @override
  List<Object?> get props => [token, name, cityName, stateUf, coversWholeCity];
}
