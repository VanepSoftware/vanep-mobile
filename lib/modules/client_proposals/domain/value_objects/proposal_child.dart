import 'package:equatable/equatable.dart';

class ProposalChild extends Equatable {
  const ProposalChild({
    required this.token,
    required this.name,
    this.birthDate,
  });

  final String token;

  final String name;

  final String? birthDate;

  @override
  List<Object?> get props => [token, name, birthDate];
}
