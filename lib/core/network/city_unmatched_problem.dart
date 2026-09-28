const ibgeCityUnmatchedCode = 'location.city.unmatched';

const ibgeCityUnmatchedDetailMarkers = [
  'município brasileiro',
  'municipio brasileiro',
  'brazilian municipality',
];

bool isIbgeCityUnmatchedProblem(Object? body) {
  if (body is! Map) return false;
  if (body['code'] == ibgeCityUnmatchedCode) return true;
  final detail = body['detail'];
  if (detail is! String) return false;
  final normalized = detail.toLowerCase();
  return ibgeCityUnmatchedDetailMarkers.any(normalized.contains);
}
