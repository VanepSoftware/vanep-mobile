import '../../../../core/formatters/postal_address_display.dart';
import '../../domain/entities/personal_address.dart';

PostalAddressDisplayFields personalAddressDisplayFields(
  PersonalAddress address,
) {
  return postalAddressDisplayFields(
    street: address.street,
    number: address.number,
    complement: address.complement,
    neighborhood: address.neighborhood,
    cityName: address.cityName,
    uf: address.stateUf,
    zipCode: address.zipCode,
  );
}
