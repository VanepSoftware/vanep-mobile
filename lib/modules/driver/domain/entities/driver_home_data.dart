import '../value_objects/home_phase.dart';
import '../value_objects/registration_status.dart';
import '../value_objects/stop_action.dart';
import '../value_objects/trip_status.dart';

export '../value_objects/home_phase.dart';
export '../value_objects/registration_status.dart';
export '../value_objects/shortcut.dart';
export '../value_objects/stop_action.dart';
export '../value_objects/trip_status.dart';

class Trip {
  const Trip({
    required this.id,
    required this.status,
    required this.label,
    this.shift,
  });
  final String id;
  final TripStatus status;
  final String label;
  final String? shift;
}

class StopConfirmation {
  const StopConfirmation({
    required this.tripId, required this.stopId, required this.studentId,
    required this.studentName, required this.action,
  });
  final String tripId;
  final String stopId;
  final String studentId;
  final String studentName;
  final StopAction action;
}

class DriverHomeData {
  const DriverHomeData({
    required this.registration, this.subscriptionBlocked = false,
    this.expiredDocument = false, this.rejectionReason,
    this.todayTrip, this.laterShiftLabel, this.studentCount = 0,
    this.familiesInApp = 0, this.outsideWorkingHours = false,
    this.nextConfirmation, this.contactLabel,
  }) : assert(studentCount >= 0), assert(familiesInApp >= 0);
  final RegistrationStatus registration;
  final bool subscriptionBlocked;
  final bool expiredDocument;
  final String? rejectionReason;
  // The adapter supplies the current day's trip using the business timezone.
  final Trip? todayTrip;
  final String? laterShiftLabel;
  final int studentCount;
  final int familiesInApp;
  final bool outsideWorkingHours;
  final StopConfirmation? nextConfirmation;
  final String? contactLabel;

  bool get isOperating => todayTrip?.status == TripStatus.inProgress;
  bool get isBlocked => subscriptionBlocked || expiredDocument;
  String get blockReason => [
    if (subscriptionBlocked) 'Regularize sua assinatura Vanep.',
    if (expiredDocument) 'Atualize os documentos vencidos.',
  ].join(' ');
}

class HomeState {
  const HomeState(this.phase, {this.blockBanner});
  final HomePhase phase;
  final String? blockBanner;
}
