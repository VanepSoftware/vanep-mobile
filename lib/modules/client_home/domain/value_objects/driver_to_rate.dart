import 'package:equatable/equatable.dart';

class DriverToRate extends Equatable {
  const DriverToRate({required this.token, required this.name});

  final String token;

  final String name;

  @override
  List<Object?> get props => [token, name];
}
