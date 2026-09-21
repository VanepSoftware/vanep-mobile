import 'package:equatable/equatable.dart';

class BrazilianCity extends Equatable {
  const BrazilianCity({
    required this.token,
    required this.name,
    required this.stateToken,
    required this.stateUf,
    required this.active,
    this.createdAt,
  });

  final String token;

  final String name;

  final String stateToken;

  final String stateUf;

  final bool active;

  final DateTime? createdAt;

  @override
  List<Object?> get props => [
    token,
    name,
    stateToken,
    stateUf,
    active,
    createdAt,
  ];
}
