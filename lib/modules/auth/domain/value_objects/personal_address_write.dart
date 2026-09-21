import 'package:equatable/equatable.dart';

import '../../../../core/domain/postal_address_draft.dart';

class PersonalAddressWrite extends Equatable {
  const PersonalAddressWrite({
    required this.cityToken,
    required this.street,
    required this.zipCode,
    this.number,
    this.complement,
    this.neighborhood,
  });

  final String cityToken;
  final String street;
  final String zipCode;
  final String? number;
  final String? complement;
  final String? neighborhood;

  @override
  List<Object?> get props => [
    cityToken,
    street,
    zipCode,
    number,
    complement,
    neighborhood,
  ];
}

PersonalAddressWrite? personalAddressWriteFromDraft(PostalAddressDraft draft) {
  if (!draft.isSavable) return null;
  return PersonalAddressWrite(
    cityToken: draft.cityToken,
    street: draft.street.trim(),
    zipCode: draft.zipCode,
    number: blankToNull(draft.number),
    complement: blankToNull(draft.complement),
    neighborhood: blankToNull(draft.neighborhood),
  );
}
