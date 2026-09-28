import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/personal_address_failure.dart';
import 'package:vanep_mobile/modules/auth/presentation/mappers/personal_address_failure_l10n.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/cep_failure.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/ibge_locations_failure.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  test('maps each PersonalAddressFailure to ARB copy', () {
    expect(
      personalAddressFailureMessage(l10n, PersonalAddressFailure.cityNotFound),
      'City not found in the catalog.',
    );
    expect(
      personalAddressFailureMessage(l10n, PersonalAddressFailure.validation),
      'Please review the address fields and try again.',
    );
    expect(
      personalAddressFailureMessage(l10n, PersonalAddressFailure.network),
      'No connection to the server. Please try again.',
    );
    expect(
      personalAddressFailureMessage(l10n, PersonalAddressFailure.unexpected),
      'Something went wrong. Please try again.',
    );
  });

  test('maps each CepFailure to ARB copy', () {
    expect(
      cepFailureMessage(l10n, CepFailure.invalidFormat),
      'ZIP code must have 8 digits.',
    );
    expect(cepFailureMessage(l10n, CepFailure.notFound), 'ZIP code not found.');
    expect(
      cepFailureMessage(l10n, CepFailure.cityNotInCatalog),
      'This ZIP code city is not in the catalog.',
    );
    expect(
      cepFailureMessage(l10n, CepFailure.rateLimited),
      'Too many ZIP lookups. Please wait a moment.',
    );
    expect(
      cepFailureMessage(l10n, CepFailure.unavailable),
      'ZIP lookup is unavailable. Please fill in the address.',
    );
    expect(
      cepFailureMessage(l10n, CepFailure.network),
      'No connection to the server. Please try again.',
    );
    expect(
      cepFailureMessage(l10n, CepFailure.unexpected),
      'Something went wrong. Please try again.',
    );
  });

  test('maps each IbgeLocationsFailure to ARB copy', () {
    expect(
      ibgeLocationsFailureMessage(l10n, IbgeLocationsFailure.ufMissing),
      'Please choose a state.',
    );
    expect(
      ibgeLocationsFailureMessage(l10n, IbgeLocationsFailure.ufNotFound),
      'State not found.',
    );
    expect(
      ibgeLocationsFailureMessage(l10n, IbgeLocationsFailure.network),
      'No connection to the server. Please try again.',
    );
    expect(
      ibgeLocationsFailureMessage(l10n, IbgeLocationsFailure.unexpected),
      'Something went wrong. Please try again.',
    );
  });
}
