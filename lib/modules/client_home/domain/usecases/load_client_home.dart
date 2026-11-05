import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/client_home/domain/failures/client_home_failure.dart';
import 'package:vanep_mobile/modules/client_home/domain/repositories/client_home_repository.dart';
import 'package:vanep_mobile/modules/client_home/domain/usecases/prioritize_needs_you_items.dart';
import 'package:vanep_mobile/modules/client_home/domain/usecases/resolve_enabled_shortcuts.dart';
import 'package:vanep_mobile/modules/client_home/domain/usecases/resolve_home_headline.dart';
import 'package:vanep_mobile/modules/client_home/domain/usecases/resolve_section_without_van.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/client_home.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/today_section.dart';

class LoadClientHome {
  const LoadClientHome({
    required this.repository,
    required this.resolveSectionWithoutVan,
    required this.prioritizeNeedsYouItems,
    required this.resolveEnabledShortcuts,
    required this.resolveHomeHeadline,
    this.clock = DateTime.now,
  });

  final ClientHomeRepository repository;

  final ResolveSectionWithoutVan resolveSectionWithoutVan;

  final PrioritizeNeedsYouItems prioritizeNeedsYouItems;

  final ResolveEnabledShortcuts resolveEnabledShortcuts;

  final ResolveHomeHeadline resolveHomeHeadline;

  final DateTime Function() clock;

  Future<Result<ClientHomeFailure, ClientHome>> call() async {
    final overviewResult = await repository.findDailyOverview();
    final overviewFailure = overviewResult.errorOrNull;
    if (overviewFailure != null) return Err(overviewFailure);
    final overview = overviewResult.valueOrNull!;

    final sectionResult = await findTodaySection(overview);
    return sectionResult.fold(
      Err.new,
      (today) => Ok(assembleHome(today: today, overview: overview)),
    );
  }

  Future<Result<ClientHomeFailure, TodaySection>> findTodaySection(
    DailyOverview overview,
  ) async {
    final today = overview.today;
    if (today != null) return Ok(today);
    return resolveSectionWithoutVan();
  }

  ClientHome assembleHome({
    required TodaySection today,
    required DailyOverview overview,
  }) {
    final now = clock();
    return ClientHome(
      date: now,
      headline: resolveHomeHeadline(today: today, now: now),
      today: today,
      needsYou: prioritizeNeedsYouItems(overview.needsYou),
      enabledShortcuts: resolveEnabledShortcuts(today),
    );
  }
}
