import 'package:equatable/equatable.dart';

class CepLookup extends Equatable {
  const CepLookup({
    required this.cityToken,
    required this.cityName,
    required this.uf,
    this.street,
    this.neighborhood,
  });

  final String cityToken;

  final String cityName;

  final String uf;

  final String? street;

  final String? neighborhood;

  @override
  List<Object?> get props => [cityToken, cityName, uf, street, neighborhood];
}
