import 'package:equatable/equatable.dart';

import '../entities/dependent.dart';

class DependentAddressDraft extends Equatable {
  const DependentAddressDraft({
    this.placeId,
    this.sessionToken,
    this.label = '',
    this.number,
    this.complement,
  });

  factory DependentAddressDraft.fromAddress(DependentAddress address) {
    return DependentAddressDraft(
      label: address.street,
      number: address.number,
      complement: address.complement,
    );
  }

  final String? placeId;

  final String? sessionToken;

  final String label;

  final String? number;

  final String? complement;

  bool get carriesANewPlace => placeId != null && placeId!.isNotEmpty;

  DependentAddressDraft withNumber(String? value) {
    return DependentAddressDraft(
      placeId: placeId,
      sessionToken: sessionToken,
      label: label,
      number: value,
      complement: complement,
    );
  }

  DependentAddressDraft withComplement(String? value) {
    return DependentAddressDraft(
      placeId: placeId,
      sessionToken: sessionToken,
      label: label,
      number: number,
      complement: value,
    );
  }

  @override
  List<Object?> get props => [placeId, sessionToken, label, number, complement];
}
