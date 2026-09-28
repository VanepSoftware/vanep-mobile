import 'package:vanep_mobile/core/domain/postal_address_draft.dart';

PostalAddressDraft fakeCompleteDraft({
  String zipCode = '72120120',
  String cityToken = 'city-brasilia',
  String cityName = 'Brasília',
  String uf = 'DF',
  String street = 'QND 12',
  String neighborhood = '',
  String number = '',
  String complement = '',
}) {
  return PostalAddressDraft(
    zipCode: zipCode,
    cityToken: cityToken,
    cityName: cityName,
    uf: uf,
    street: street,
    neighborhood: neighborhood,
    number: number,
    complement: complement,
  );
}

PostalAddressDraft fakeResolvedDraft({
  String cityName = 'Brasília',
  String uf = 'DF',
  String? street = 'QND 12',
  String? neighborhood,
}) {
  return const PostalAddressDraft()
      .withZipCode('72120120')
      .withCepLookup(
        cityToken: 'city-brasilia',
        cityName: cityName,
        uf: uf,
        street: street,
        neighborhood: neighborhood,
      );
}

PostalAddressDraft fakeManualDraft() {
  return const PostalAddressDraft()
      .withZipCode('72120120')
      .withCepUnavailable();
}

PostalAddressDraft fakeBlockedDraft() {
  return const PostalAddressDraft().withZipCode('72120120').withCepUnknown();
}
