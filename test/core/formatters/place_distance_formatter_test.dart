import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/formatters/place_distance_formatter.dart';
import 'package:vanep_mobile/core/places/place_suggestion.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';

const schoolAt = PlaceSuggestion(
  placeId: 'place-1',
  primaryText: 'Escola Classe 10',
  secondaryText: 'Taguatinga Norte',
  distanceMeters: 850,
);

void main() {
  test('formats distances in Portuguese', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('pt'));

    expect(formatPlaceDistance(l10n, 850), '850 m');
    expect(formatPlaceDistance(l10n, 2400), '2,4 km');
    expect(formatPlaceDistance(l10n, 37000), '37 km');
    expect(formatPlaceDistance(l10n, 37600), '38 km');
  });

  test('formats distances in English', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    expect(formatPlaceDistance(l10n, 850), '850 m');
    expect(formatPlaceDistance(l10n, 2400), '2.4 km');
    expect(formatPlaceDistance(l10n, 37000), '37 km');
  });

  test('puts the distance before the region of a suggestion', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('pt'));

    expect(placeSuggestionSubtitle(l10n, schoolAt), '850 m · Taguatinga Norte');
  });

  test('a suggestion without distance keeps only its region', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('pt'));
    const withoutDistance = PlaceSuggestion(
      placeId: 'place-1',
      primaryText: 'Escola Classe 10',
      secondaryText: 'Taguatinga Norte',
    );

    expect(placeSuggestionSubtitle(l10n, withoutDistance), 'Taguatinga Norte');
  });

  test('a suggestion without region shows only the distance', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('pt'));
    const withoutRegion = PlaceSuggestion(
      placeId: 'place-1',
      primaryText: 'Escola Classe 10',
      secondaryText: '',
      distanceMeters: 2400,
    );

    expect(placeSuggestionSubtitle(l10n, withoutRegion), '2,4 km');
  });
}
