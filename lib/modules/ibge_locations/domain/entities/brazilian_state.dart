import 'package:equatable/equatable.dart';

class BrazilianState extends Equatable {
  const BrazilianState({
    required this.token,
    required this.name,
    required this.uf,
    required this.active,
  });

  final String token;

  final String name;

  final String uf;

  final bool active;

  @override
  List<Object?> get props => [token, name, uf, active];
}
