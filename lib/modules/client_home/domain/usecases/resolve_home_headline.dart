import 'package:vanep_mobile/modules/client_home/domain/value_objects/client_home.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/today_section.dart';

const afternoonStartsAtHour = 12;

const eveningStartsAtHour = 18;

bool isWeekend(DateTime moment) =>
    moment.weekday == DateTime.saturday || moment.weekday == DateTime.sunday;

HomeHeadline headlineForTimeOfDay(DateTime now) {
  if (now.hour < afternoonStartsAtHour) return HomeHeadline.goodMorning;
  if (now.hour < eveningStartsAtHour) return HomeHeadline.goodAfternoon;
  return HomeHeadline.goodEvening;
}

class ResolveHomeHeadline {
  const ResolveHomeHeadline();

  HomeHeadline call({required TodaySection today, required DateTime now}) {
    return switch (today) {
      FirstStepsSection() ||
      NoLinkedVanSection() ||
      NegotiatingSection() => HomeHeadline.hello,
      ArrivedSection() => HomeHeadline.allGood,
      VanDaySection(isVanApproaching: true) => HomeHeadline.vanArriving,
      NoRouteTodaySection() when isWeekend(now) => HomeHeadline.goodWeekend,
      VanDaySection() || NoRouteTodaySection() => headlineForTimeOfDay(now),
    };
  }
}
