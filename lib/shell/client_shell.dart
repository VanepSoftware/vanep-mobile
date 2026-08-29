import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/design_system/vanep_colors.dart';
import '../core/places/place_autocomplete_controller.dart';
import '../core/ui/vanep_coming_soon.dart';
import '../l10n/app_localizations.dart';
import '../modules/auth/domain/entities/user_profile.dart';
import '../modules/auth/presentation/cubit/auth_cubit.dart';
import '../modules/auth/presentation/pages/profile_page.dart';
import '../modules/drivers/presentation/pages/drivers_home_tab.dart';
import '../modules/driversearch/presentation/pages/driver_search_page.dart';
import '../modules/profile/presentation/cubit/profile_summary_cubit.dart';
import '../modules/profile/presentation/formatters/assistant_status_label.dart';
import 'client_bottom_nav.dart';

const clientShellSearchTabIndex = 1;
const clientShellProfileTabIndex = 3;

class ClientShell extends StatefulWidget {
  const ClientShell({
    required this.profile,
    required this.createPlaceAutocomplete,
    super.key,
  });

  final UserProfile profile;

  final PlaceAutocompleteController Function() createPlaceAutocomplete;

  @override
  State<ClientShell> createState() => ClientShellState();
}

class ClientShellState extends State<ClientShell> {
  int selectedIndex = 0;

  late final PlaceAutocompleteController placeAutocomplete;

  @override
  void initState() {
    super.initState();
    placeAutocomplete = widget.createPlaceAutocomplete();
  }

  @override
  void dispose() {
    placeAutocomplete.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayName = widget.profile.name ?? widget.profile.email ?? '';

    return Scaffold(
      extendBody: true,
      backgroundColor: VanepColors.surface,
      body: IndexedStack(
        index: selectedIndex,
        children: [
          DriversHomeTab(
            displayName: displayName,
            onSearchTapped: openSearchTab,
          ),
          DriverSearchPage(autocomplete: placeAutocomplete),
          VanepComingSoon(
            title: l10n.navNotifications,
            message: l10n.comingSoon,
          ),
          BlocBuilder<ProfileSummaryCubit, ProfileSummaryState>(
            builder: (context, summaryState) {
              return ProfilePage(
                profile: widget.profile,
                photoUrl: summaryState.photoUrl,
                rating: summaryState.rating,
                city: summaryState.city,
                statusLabel: assistantStatusLabel(
                  l10n,
                  summaryState.assistantStatus,
                ),
                statusColor: assistantStatusColor(summaryState.assistantStatus),
                onRefresh: refreshProfileTab,
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Material(
        type: MaterialType.transparency,
        child: ClientBottomNav(
          currentIndex: selectedIndex,
          onDestinationSelected: selectShellTab,
        ),
      ),
    );
  }

  void openSearchTab() => selectShellTab(clientShellSearchTabIndex);

  void selectShellTab(int index) {
    setState(() => selectedIndex = index);
    if (index != clientShellProfileTabIndex) return;
    refreshProfileTab();
  }

  Future<void> refreshProfileTab() {
    return Future.wait<void>([
      context.read<AuthCubit>().refreshSessionProfile(),
      context.read<ProfileSummaryCubit>().refresh(widget.profile.type),
    ]);
  }
}
