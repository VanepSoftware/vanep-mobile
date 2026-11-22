import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/mocked_assistant_route_datasource.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_boarding_history.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_student_detail.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/boarding_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/no_show_reason.dart';

abstract class AssistantStudentDetailDataSource {
  Future<AssistantStudentDetail> findStudentDetail(String studentToken);

  Future<List<AssistantBoardingHistoryDay>> findBoardingHistory(
    String studentToken,
  );
}

const mockedNoShowEverySchoolDays = 7;
const mockedAbsentEverySchoolDays = 11;

String mockedNameKeyOf(String token) => token.split('-').last;

const mockedSchoolDays = {
  Weekday.monday,
  Weekday.tuesday,
  Weekday.wednesday,
  Weekday.thursday,
  Weekday.friday,
};

// TODO(VAN-74): mocked student detail of the prototype (frame
// aux-alunos-2-detalhe). Real data needs a student read for the assistant
// (backend B13), the driver's note, which is not modeled in vanep-dbdiagram
// (B14), the guardian contact (B15) and a 30-day read of checklist_entry for
// the boarding history (B16). Product allowed the assistant to see the guardian
// contact (2026-11-15). Delete this class and its registration in
// assistant_container.dart when they are wired.
class MockedAssistantStudentDetailDataSource
    implements AssistantStudentDetailDataSource {
  const MockedAssistantStudentDetailDataSource({this.clock = DateTime.now});

  final DateTime Function() clock;

  @override
  Future<AssistantStudentDetail> findStudentDetail(String studentToken) async {
    final now = clock();
    final today = DateTime(now.year, now.month, now.day);
    final stop = mockedHomeStops.firstWhere(
      (candidate) => candidate.passengers.any(
        (name) =>
            mockedNameKeyOf(mockedPassengerToken(name)) ==
            mockedNameKeyOf(studentToken),
      ),
      orElse: () => mockedHomeStops.first,
    );
    final name = stop.passengers.firstWhere(
      (candidate) =>
          mockedNameKeyOf(mockedPassengerToken(candidate)) ==
          mockedNameKeyOf(studentToken),
      orElse: () => stop.passengers.first,
    );
    final pickupAt = today.add(
      Duration(hours: 6, minutes: stop.minutesAfterSix),
    );

    return AssistantStudentDetail(
      token: studentToken,
      name: name,
      schoolName: mockedSchoolOf(name),
      shift: mockedVanCarlos.shift,
      pickupAddress: stop.label,
      pickupWindowStart: pickupAt.subtract(const Duration(minutes: 5)),
      pickupWindowEnd: pickupAt.add(const Duration(minutes: 5)),
      returnDepartureAt: today.add(const Duration(hours: 12, minutes: 30)),
      outboundDays: mockedSchoolDays,
      inboundDays: mockedSchoolDays,
      siblings: [
        for (final sibling in stop.passengers)
          if (sibling != name)
            AssistantStudentSibling(
              token: mockedPassengerToken(sibling),
              name: sibling,
              relationship: 'Irmão',
              schoolName: mockedSchoolOf(sibling),
            ),
      ],
      guardian: const AssistantStudentGuardian(
        name: 'Patrícia Santos',
        relationship: 'Mãe',
        phone: '(61) 99999-0000',
      ),
      canSeeGuardianContact: true,
      driverNote: 'Desembarque pelo portão lateral.',
    );
  }

  @override
  Future<List<AssistantBoardingHistoryDay>> findBoardingHistory(
    String studentToken,
  ) async {
    final now = clock();
    final today = DateTime(now.year, now.month, now.day);
    final schoolDays = [
      for (var back = 1; back <= assistantBoardingHistoryDays; back++)
        today.subtract(Duration(days: back)),
    ].where((day) => day.weekday <= DateTime.friday).toList();

    DateTime at(DateTime day, int hour, int minute) =>
        day.add(Duration(hours: hour, minutes: minute));

    return [
      for (final (index, day) in schoolDays.indexed)
        if (index % mockedAbsentEverySchoolDays ==
            mockedAbsentEverySchoolDays - 1)
          AssistantBoardingHistoryDay(
            date: day,
            outbound: const AssistantLegRecord(
              status: BoardingStatus.notGoingToday,
            ),
            inbound: const AssistantLegRecord(
              status: BoardingStatus.notGoingToday,
            ),
          )
        else if (index % mockedNoShowEverySchoolDays ==
            mockedNoShowEverySchoolDays - 1)
          AssistantBoardingHistoryDay(
            date: day,
            outbound: AssistantLegRecord(
              status: BoardingStatus.noShow,
              boardedAt: at(day, 6, 48),
              noShowReason: NoShowReason.notAtStop,
            ),
          )
        else
          AssistantBoardingHistoryDay(
            date: day,
            outbound: AssistantLegRecord(
              status: BoardingStatus.droppedOff,
              boardedAt: at(day, 6, 48),
              droppedOffAt: at(day, 7, 15),
            ),
            inbound: AssistantLegRecord(
              status: BoardingStatus.droppedOff,
              boardedAt: at(day, 12, 32),
              droppedOffAt: at(day, 12, 58),
            ),
          ),
    ];
  }
}
