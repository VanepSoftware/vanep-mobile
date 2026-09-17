import 'package:equatable/equatable.dart';

class GoogleSignupTicket extends Equatable {
  const GoogleSignupTicket({
    required this.ticket,
    required this.email,
    required this.name,
  });

  final String ticket;
  final String email;
  final String name;

  @override
  List<Object?> get props => [ticket, email, name];
}
