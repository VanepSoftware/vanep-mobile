import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/assistant/domain/value_objects/no_show_reason.dart';

class StopConfirmation extends Equatable {
  const StopConfirmation({
    required this.vanToken,
    required this.stopToken,
    required this.confirmedPassengerTokens,
    this.skippedPassengers = const {},
    this.skipNotes = const {},
  });

  final String vanToken;
  final String stopToken;
  final List<String> confirmedPassengerTokens;
  final Map<String, NoShowReason> skippedPassengers;
  final Map<String, String> skipNotes;

  int get confirmedCount => confirmedPassengerTokens.length;

  @override
  List<Object?> get props => [
    vanToken,
    stopToken,
    confirmedPassengerTokens,
    skippedPassengers,
    skipNotes,
  ];
}
