import 'dart:math';

import 'package:vanep_mobile/modules/negotiations/domain/value_objects/draft_text.dart';

const declineReasonMaxLength = 500;

const declineReasonSeparator = '. ';

String composeDeclineReason(String reason, String message) {
  final trimmedMessage = trimmedOrNull(message);
  if (trimmedMessage == null) return reason;
  return '$reason$declineReasonSeparator$trimmedMessage';
}

int declineMessageMaxLength(Iterable<String> reasons) {
  final longestReason = reasons.map((reason) => reason.length).fold(0, max);
  return declineReasonMaxLength - longestReason - declineReasonSeparator.length;
}

bool fitsDeclineReasonLimit(String reason, String message) {
  return composeDeclineReason(reason, message).length <= declineReasonMaxLength;
}
