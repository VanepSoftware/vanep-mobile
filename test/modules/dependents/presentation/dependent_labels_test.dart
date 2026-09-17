import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';
import 'package:vanep_mobile/modules/dependents/presentation/formatters/dependent_labels.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('pt'));
  });

  test('findAgeInYears uses the calendar day, not UTC midnight', () {
    expect(
      findAgeInYears('2015-03-22', today: DateTime(2015, 3, 22)),
      0,
    );
    expect(
      findAgeInYears('2015-03-22', today: DateTime(2026, 3, 21)),
      10,
    );
    expect(
      findAgeInYears('2015-03-22', today: DateTime(2026, 3, 22)),
      11,
    );
  });

  test('dependentAgeLabel follows the years found', () {
    expect(
      dependentAgeLabel(l10n, '2015-03-22', today: DateTime(2026, 9, 14)),
      '11 anos',
    );
    expect(dependentAgeLabel(l10n, null, today: DateTime(2026, 9, 14)), isNull);
  });

  test('a field-attributed validation failure stays off the snackbar', () {
    expect(
      shouldShowDependentFailureFeedback(
        const DependentValidationFailure(
          messagesByField: {DependentField.name: 'Nome muito longo.'},
        ),
      ),
      isFalse,
    );
  });

  test('a failure without a field goes to the snackbar', () {
    expect(
      shouldShowDependentFailureFeedback(const DependentNetworkFailure()),
      isTrue,
    );
    expect(
      shouldShowDependentFailureFeedback(
        const DependentValidationFailure(detail: 'Nome muito longo.'),
      ),
      isTrue,
    );
    expect(shouldShowDependentFailureFeedback(null), isFalse);
  });
}
