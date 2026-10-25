import 'package:equatable/equatable.dart';

class School extends Equatable {
  const School({required this.token, required this.name});

  final String token;

  final String name;

  @override
  List<Object?> get props => [token, name];
}
