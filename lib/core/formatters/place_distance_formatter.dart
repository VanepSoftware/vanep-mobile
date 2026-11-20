import 'package:intl/intl.dart';

import 'package:vanep_mobile/core/places/place_suggestion.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';

const metersPerKilometer = 1000;
const kilometersWithDecimalBelow = 10;

String formatPlaceDistance(AppLocalizations l10n, int meters) {
  if (meters < metersPerKilometer) {
    return l10n.placeDistanceMeters(
      NumberFormat('0', l10n.localeName).format(meters),
    );
  }
  final kilometers = meters / metersPerKilometer;
  final pattern = kilometers < kilometersWithDecimalBelow ? '0.0' : '0';
  return l10n.placeDistanceKilometers(
    NumberFormat(pattern, l10n.localeName).format(kilometers),
  );
}

String placeSuggestionSubtitle(
  AppLocalizations l10n,
  PlaceSuggestion suggestion,
) {
  final meters = suggestion.distanceMeters;
  if (meters == null) return suggestion.secondaryText;
  final distance = formatPlaceDistance(l10n, meters);
  if (suggestion.secondaryText.isEmpty) return distance;
  return l10n.placeSuggestionDistanceAndRegion(
    distance,
    suggestion.secondaryText,
  );
}
