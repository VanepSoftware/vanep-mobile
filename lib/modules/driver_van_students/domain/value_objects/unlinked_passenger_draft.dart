import 'package:equatable/equatable.dart';
import 'package:vanep_mobile/core/domain/postal_address_draft.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/core/domain/schedule/clock_time.dart';
import 'package:vanep_mobile/core/domain/schedule/operation_shift.dart';
import 'package:vanep_mobile/core/domain/schedule/route_leg.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/modules/schools/domain/entities/school.dart';

const unlinkedPassengerNameMaxLength = 255;

const unlinkedPassengerNotesMaxLength = 500;

enum UnlinkedPassengerDraftError {
  nameRequired,
  nameTooLong,
  schoolRequired,
  schoolShiftRequired,
  cityRequired,
  streetRequired,
  zipCodeInvalid,
  legRequired,
  timeRequired,
  notesTooLong,
}

typedef WeekdayLeg = (Weekday, RouteLeg);

const defaultOutboundPickupTime = ClockTime(hour: 8, minute: 0);

const defaultHomeboundPickupTime = ClockTime(hour: 18, minute: 0);

const initialLegPickupTimes = {
  RouteLeg.outbound: defaultOutboundPickupTime,
  RouteLeg.homebound: defaultHomeboundPickupTime,
};

class UnlinkedPassengerSlot extends Equatable {
  const UnlinkedPassengerSlot({
    required this.weekday,
    required this.leg,
    required this.shift,
    required this.pickupTime,
  });

  final Weekday weekday;

  final RouteLeg leg;

  final OperationShift shift;

  final ClockTime pickupTime;

  @override
  List<Object?> get props => [weekday, leg, shift, pickupTime];
}

class UnlinkedPassengerDraft extends Equatable {
  const UnlinkedPassengerDraft({
    this.name = '',
    this.school,
    this.schoolShift,
    this.address = const PostalAddressDraft(),
    this.legTimes = const {},
    this.defaultTimes = initialLegPickupTimes,
    this.notes = '',
    this.vehicleToken,
  });

  final String name;

  final School? school;

  final SchoolShift? schoolShift;

  final PostalAddressDraft address;

  final Map<WeekdayLeg, ClockTime?> legTimes;

  final Map<RouteLeg, ClockTime> defaultTimes;

  final String notes;

  final String? vehicleToken;

  bool isLegSelected(Weekday weekday, RouteLeg leg) {
    return legTimes.containsKey((weekday, leg));
  }

  ClockTime? timeOf(Weekday weekday, RouteLeg leg) => legTimes[(weekday, leg)];

  ClockTime defaultTimeOf(RouteLeg leg) {
    final saved = defaultTimes[leg];
    if (saved != null) return saved;
    return switch (leg) {
      RouteLeg.outbound => defaultOutboundPickupTime,
      RouteLeg.homebound => defaultHomeboundPickupTime,
    };
  }

  UnlinkedPassengerDraft toggleLeg(Weekday weekday, RouteLeg leg) {
    final next = {...legTimes};
    final slot = (weekday, leg);
    if (next.containsKey(slot)) {
      next.remove(slot);
    } else {
      next[slot] = defaultTimeOf(leg);
    }
    return copyWith(legTimes: next);
  }

  UnlinkedPassengerDraft changeDefaultTime(RouteLeg leg, ClockTime time) {
    if (defaultTimeOf(leg) == time) return this;
    return copyWith(defaultTimes: {...defaultTimes, leg: time});
  }

  UnlinkedPassengerDraft changeTime(
    Weekday weekday,
    RouteLeg leg,
    ClockTime time,
  ) {
    if (!isLegSelected(weekday, leg)) return this;
    return copyWith(legTimes: {...legTimes, (weekday, leg): time});
  }

  UnlinkedPassengerDraft applyTimeToEveryDay(RouteLeg leg, ClockTime time) {
    return copyWith(
      legTimes: {
        for (final MapEntry(key: weekdayLeg, value: current)
            in legTimes.entries)
          weekdayLeg: weekdayLeg.$2 == leg ? time : current,
      },
    );
  }

  Set<UnlinkedPassengerDraftError> get errors {
    final trimmedName = name.trim();
    final addressIssues = address.issues;
    return {
      if (trimmedName.isEmpty) UnlinkedPassengerDraftError.nameRequired,
      if (trimmedName.length > unlinkedPassengerNameMaxLength)
        UnlinkedPassengerDraftError.nameTooLong,
      if (school == null) UnlinkedPassengerDraftError.schoolRequired,
      if (schoolShift == null) UnlinkedPassengerDraftError.schoolShiftRequired,
      if (addressIssues.contains(PostalAddressIssue.cityRequired))
        UnlinkedPassengerDraftError.cityRequired,
      if (addressIssues.contains(PostalAddressIssue.streetRequired))
        UnlinkedPassengerDraftError.streetRequired,
      if (addressIssues.contains(PostalAddressIssue.zipCodeInvalid))
        UnlinkedPassengerDraftError.zipCodeInvalid,
      if (legTimes.isEmpty) UnlinkedPassengerDraftError.legRequired,
      if (legTimes.values.any((time) => time == null))
        UnlinkedPassengerDraftError.timeRequired,
      if (notes.trim().length > unlinkedPassengerNotesMaxLength)
        UnlinkedPassengerDraftError.notesTooLong,
    };
  }

  bool get isValid => errors.isEmpty;

  List<UnlinkedPassengerSlot> get slots {
    return [
      for (final weekday in Weekday.values)
        for (final leg in RouteLeg.values)
          if (legTimes[(weekday, leg)] case final time?)
            UnlinkedPassengerSlot(
              weekday: weekday,
              leg: leg,
              shift: deriveOperationShift(schoolShift, leg),
              pickupTime: time,
            ),
    ];
  }

  UnlinkedPassengerDraft copyWith({
    String? name,
    School? school,
    SchoolShift? schoolShift,
    PostalAddressDraft? address,
    Map<WeekdayLeg, ClockTime?>? legTimes,
    Map<RouteLeg, ClockTime>? defaultTimes,
    String? notes,
  }) {
    return UnlinkedPassengerDraft(
      name: name ?? this.name,
      school: school ?? this.school,
      schoolShift: schoolShift ?? this.schoolShift,
      address: address ?? this.address,
      legTimes: legTimes ?? this.legTimes,
      defaultTimes: defaultTimes ?? this.defaultTimes,
      notes: notes ?? this.notes,
      vehicleToken: vehicleToken,
    );
  }

  @override
  List<Object?> get props => [
    name,
    school,
    schoolShift,
    address,
    legTimes,
    defaultTimes,
    notes,
    vehicleToken,
  ];
}
