import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/client_home/domain/failures/client_home_failure.dart';
import 'package:vanep_mobile/modules/client_home/domain/repositories/client_home_repository.dart';
import 'package:vanep_mobile/modules/client_home/domain/usecases/find_negotiation_highlights.dart';
import 'package:vanep_mobile/modules/client_home/domain/usecases/prioritize_needs_you_items.dart';
import 'package:vanep_mobile/modules/client_home/domain/usecases/resolve_enabled_shortcuts.dart';
import 'package:vanep_mobile/modules/client_home/domain/usecases/resolve_home_headline.dart';
import 'package:vanep_mobile/modules/client_home/domain/usecases/resolve_section_without_van.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/client_home.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/needs_you_item.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/negotiation_highlights.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/today_section.dart';

class LoadClientHome {
  const LoadClientHome({
    required this.repository,
    required this.resolveSectionWithoutVan,
    required this.findNegotiationHighlights,
    required this.prioritizeNeedsYouItems,
    required this.resolveEnabledShortcuts,
    required this.resolveHomeHeadline,
    this.clock = DateTime.now,
  });

  final ClientHomeRepository repository;

  final ResolveSectionWithoutVan resolveSectionWithoutVan;

  final FindNegotiationHighlights findNegotiationHighlights;

  final PrioritizeNeedsYouItems prioritizeNeedsYouItems;

  final ResolveEnabledShortcuts resolveEnabledShortcuts;

  final ResolveHomeHeadline resolveHomeHeadline;

  final DateTime Function() clock;

  Future<Result<ClientHomeFailure, ClientHome>> call() async {
    final (overviewResult, highlights) = await (
      repository.findDailyOverview(),
      findNegotiationHighlights(),
    ).wait;
    final overviewFailure = overviewResult.errorOrNull;
    if (overviewFailure != null) return Err(overviewFailure);
    final overview = overviewResult.valueOrNull!;

    final sectionResult = await findTodaySection(overview, highlights);
    return sectionResult.fold(
      Err.new,
      (today) => Ok(
        assembleHome(
          today: today,
          needsYou: [...overview.needsYou, ...highlights.needsYouItems],
        ),
      ),
    );
  }

  Future<Result<ClientHomeFailure, TodaySection>> findTodaySection(
    DailyOverview overview,
    NegotiationHighlights highlights,
  ) async {
    final today = overview.today;
    if (today != null) return Ok(today);
    return resolveSectionWithoutVan(highlights: highlights);
  }

  ClientHome assembleHome({
    required TodaySection today,
    required List<NeedsYouItem> needsYou,
  }) {
    final now = clock();
    return ClientHome(
      date: now,
      headline: resolveHomeHeadline(today: today, now: now),
      today: today,
      needsYou: prioritizeNeedsYouItems(needsYou),
      enabledShortcuts: resolveEnabledShortcuts(today),
    );
  }
}
