import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/l10n/app_localizations_pt.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/cep_failure.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/ibge_locations_failure.dart';
import 'package:vanep_mobile/modules/dependents/presentation/formatters/dependent_labels.dart';

import '../dependents_fixtures.dart';

void main() {
  final l10n = AppLocalizationsPt();

  group('dependentFailureLabel', () {
    test('a validation failure always reads as the localized message', () {
      expect(
        dependentFailureLabel(l10n, const DependentValidationFailure()),
        l10n.dependentFailureValidation,
      );
    });

    test('a city the backend does not know has its own message', () {
      expect(
        dependentFailureLabel(l10n, const DependentCityNotFoundFailure()),
        l10n.dependentFailureCityNotFound,
      );
    });

    test('maps the remaining failures to their messages', () {
      expect(
        dependentFailureLabel(l10n, const DependentNotFoundFailure()),
        l10n.dependentFailureNotFound,
      );
      expect(
        dependentFailureLabel(l10n, const DependentNetworkFailure()),
        l10n.dependentFailureNetwork,
      );
      expect(
        dependentFailureLabel(l10n, const DependentUnexpectedFailure()),
        l10n.dependentFailureUnexpected,
      );
    });
  });

  group('shouldShowDependentFailureFeedback', () {
    test('keeps a field-attributed validation failure off the snackbar', () {
      expect(
        shouldShowDependentFailureFeedback(
          const DependentValidationFailure(
            messagesByField: {DependentField.name: 'Nome muito longo.'},
          ),
        ),
        isFalse,
      );
    });

    test('sends a failure without a field to the snackbar', () {
      expect(
        shouldShowDependentFailureFeedback(const DependentNetworkFailure()),
        isTrue,
      );
      expect(
        shouldShowDependentFailureFeedback(const DependentValidationFailure()),
        isTrue,
      );
      expect(shouldShowDependentFailureFeedback(null), isFalse);
    });

    test('keeps the city failure on the municipality field', () {
      expect(
        shouldShowDependentFailureFeedback(
          const DependentCityNotFoundFailure(),
        ),
        isFalse,
      );
    });
  });

  group('dependentAddressLabel', () {
    test('reads as empty when there is no address', () {
      expect(
        dependentAddressLabel(l10n, null),
        l10n.dependentFieldAddressEmpty,
      );
    });

    test('joins street, number, complement, neighborhood, city and cep', () {
      expect(
        dependentAddressLabel(
          l10n,
          const TestDependentAddress(complement: 'Casa 2'),
        ),
        'QNL 5 Conjunto A, 12 · Casa 2 · Taguatinga · Brasília - DF · 72120-120',
      );
    });

    test('skips the parts that were not filled in', () {
      expect(
        dependentAddressLabel(
          l10n,
          const TestDependentAddress(
            number: '',
            neighborhood: null,
            zipCode: null,
          ),
        ),
        'QNL 5 Conjunto A · Brasília - DF',
      );
    });

    test('never shows a district', () {
      expect(
        dependentAddressLabel(l10n, const TestDependentAddress()),
        isNot(contains('district')),
      );
    });
  });

  group('dependentAgeLabel', () {
    final today = DateTime(2026, 3, 22);

    test('counts the birthday on the day itself', () {
      expect(findAgeInYears('2015-03-22', today: today), 11);
    });

    test('does not count a birthday later this year', () {
      expect(findAgeInYears('2015-03-23', today: today), 10);
    });

    test('uses the calendar day, not UTC midnight', () {
      expect(findAgeInYears('2015-03-22', today: DateTime(2015, 3, 22)), 0);
      expect(findAgeInYears('2015-03-22', today: DateTime(2026, 3, 21)), 10);
    });

    test('has no age for missing, invalid or future dates', () {
      expect(dependentAgeLabel(l10n, null, today: today), isNull);
      expect(dependentAgeLabel(l10n, 'ontem', today: today), isNull);
      expect(dependentAgeLabel(l10n, '2030-01-01', today: today), isNull);
    });

    test('labels the age in years', () {
      expect(
        dependentAgeLabel(l10n, '2015-03-22', today: today),
        l10n.dependentsAgeYears(11),
      );
    });
  });

  group('catalog failure labels', () {
    test('maps every cep failure to its message', () {
      expect(
        dependentCepFailureLabel(l10n, CepFailure.invalidFormat),
        l10n.cepFailureInvalidFormat,
      );
      expect(
        dependentCepFailureLabel(l10n, CepFailure.notFound),
        l10n.cepFailureNotFound,
      );
      expect(
        dependentCepFailureLabel(l10n, CepFailure.cityNotInCatalog),
        l10n.cepFailureCityNotInCatalog,
      );
      expect(
        dependentCepFailureLabel(l10n, CepFailure.rateLimited),
        l10n.cepFailureRateLimited,
      );
      expect(
        dependentCepFailureLabel(l10n, CepFailure.unavailable),
        l10n.cepFailureUnavailable,
      );
      expect(
        dependentCepFailureLabel(l10n, CepFailure.network),
        l10n.cepFailureNetwork,
      );
      expect(
        dependentCepFailureLabel(l10n, CepFailure.unexpected),
        l10n.cepFailureUnexpected,
      );
    });

    test('maps every catalog failure to its message', () {
      expect(
        dependentCatalogFailureLabel(l10n, IbgeLocationsFailure.ufMissing),
        l10n.ibgeLocationsFailureUfMissing,
      );
      expect(
        dependentCatalogFailureLabel(l10n, IbgeLocationsFailure.ufNotFound),
        l10n.ibgeLocationsFailureUfNotFound,
      );
      expect(
        dependentCatalogFailureLabel(l10n, IbgeLocationsFailure.network),
        l10n.ibgeLocationsFailureNetwork,
      );
      expect(
        dependentCatalogFailureLabel(l10n, IbgeLocationsFailure.unexpected),
        l10n.ibgeLocationsFailureUnexpected,
      );
    });
  });
}
