import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/l10n/app_localizations_pt.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/weekday.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_wizard_step.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/cep_failure.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/ibge_locations_failure.dart';
import 'package:vanep_mobile/modules/schools/domain/failures/school_failure.dart';
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

    test('a rejection shows the message the backend sent', () {
      expect(
        dependentFailureLabel(
          l10n,
          const DependentRejectedFailure(detail: 'Escola não encontrada.'),
        ),
        'Escola não encontrada.',
      );
    });

    test('a rejection without a message falls back to the generic one', () {
      expect(
        dependentFailureLabel(l10n, const DependentRejectedFailure(detail: '')),
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

  group('rows of the new screens', () {
    final today = DateTime(2026, 10, 21);

    test('the first name is the first word of the name', () {
      expect(dependentFirstName('  Pedro Oliveira Lima '), 'Pedro');
      expect(dependentFirstName('Ana'), 'Ana');
    });

    test('the row subtitle joins the age and the school', () {
      const pedro = TestDependent(
        token: 'dep-pedro',
        name: 'Pedro Oliveira',
        birthDate: '2015-03-22',
        school: TestDependentSchool(),
      );

      expect(
        dependentRowSubtitle(l10n, pedro, today: today),
        '11 anos · Colégio Delta',
      );
    });

    test('the row subtitle drops what is missing', () {
      const davi = TestDependent(
        token: 'dep-davi',
        name: 'Davi',
        birthDate: '2022-01-10',
      );
      const ana = TestDependent(token: 'dep-ana', name: 'Ana');

      expect(dependentRowSubtitle(l10n, davi, today: today), '4 anos');
      expect(dependentRowSubtitle(l10n, ana, today: today), isNull);
    });

    test('the school address shows street, neighborhood and city', () {
      expect(
        dependentSchoolAddressLabel(const TestDependentAddress()),
        'QNL 5 Conjunto A, 12 · Taguatinga · Brasília/DF',
      );
      expect(
        dependentSchoolAddressLabel(
          const TestDependentAddress(number: null, neighborhood: null),
        ),
        'QNL 5 Conjunto A · Brasília/DF',
      );
      expect(dependentSchoolAddressLabel(null), isNull);
    });

    test('the pickup summary keeps street, number and neighborhood', () {
      expect(
        dependentPickupSummary(const TestDependentAddress(complement: 'Casa')),
        'QNL 5 Conjunto A, 12 · Taguatinga',
      );
      expect(
        dependentPickupSummary(
          const TestDependentAddress(number: null, neighborhood: null),
        ),
        'QNL 5 Conjunto A',
      );
      expect(dependentPickupSummary(null), isNull);
    });

    test('the week days, their initials and the shifts', () {
      expect(
        [for (final day in Weekday.values) weekdayLabel(l10n, day)],
        ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'],
      );
      expect(
        [for (final day in Weekday.values) weekdayInitial(l10n, day)],
        ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'],
      );
      expect(
        [for (final shift in SchoolShift.values) schoolShiftLabel(l10n, shift)],
        ['Manhã', 'Tarde', 'Noite', 'Integral'],
      );
    });

    test('the editor titles and the checklist labels', () {
      expect(
        [
          for (final step in DependentWizardStep.values)
            dependentEditorTitle(l10n, step),
        ],
        ['Dados pessoais', 'Escola', 'Dias e turnos', 'Embarque'],
      );
      expect(
        dependentReadinessItemLabel(l10n, DependentWizardStep.personalData),
        'Data de nascimento',
      );
    });
  });

  test('a school rejection shows the message of the back', () {
    expect(
      dependentSchoolFailureLabel(
        l10n,
        const SchoolRejectedFailure(detail: 'Este local não é uma escola.'),
      ),
      'Este local não é uma escola.',
    );
    expect(
      dependentSchoolFailureLabel(
        l10n,
        const SchoolRejectedFailure(detail: ''),
      ),
      l10n.dependentFailureUnexpected,
    );
    expect(
      dependentSchoolFailureLabel(l10n, const SchoolNetworkFailure()),
      l10n.dependentFailureNetwork,
    );
  });
}
