import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/design_system/vanep_colors.dart';
import '../core/ui/vanep_coming_soon.dart';
import '../l10n/app_localizations.dart';
import '../modules/auth/domain/entities/user_profile.dart';
import '../modules/client/presentation/pages/client_home_tab.dart';
import '../modules/dependents/presentation/cubit/dependents_cubit.dart';
import '../modules/dependents/presentation/pages/dependents_page.dart';
import '../modules/drivers/presentation/pages/find_vans_tab.dart';
import 'client_bottom_nav.dart';
import 'shell_account_drawer.dart';

const clientShellVansTabIndex = 1;

const clientShellDependentsTabIndex = 3;

class ClientShell extends StatefulWidget {
  const ClientShell({
    required this.profile,
    required this.openDriverSearch,
    super.key,
  });

  final UserProfile profile;

  final Future<void> Function(BuildContext context) openDriverSearch;

  @override
  State<ClientShell> createState() => ClientShellState();
}

class ClientShellState extends State<ClientShell> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayName = widget.profile.name ?? widget.profile.email ?? '';

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: VanepColors.surface,
      drawer: ShellAccountDrawer(profile: widget.profile),
      onDrawerChanged: (isOpened) => refreshAccountWhenDrawerOpens(
        context,
        widget.profile,
        isOpened: isOpened,
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: [
          ClientHomeTab(
            displayName: displayName,
            onMenuTapped: () => scaffoldKey.currentState?.openDrawer(),
            onNotificationsTapped: () => openNotifications(context),
            onFindVanTapped: () => selectShellTab(clientShellVansTabIndex),
          ),
          FindVansTab(onSearchTapped: () => widget.openDriverSearch(context)),
          VanepComingSoon(title: l10n.navContracts, message: l10n.comingSoon),
          const DependentsPage(),
        ],
      ),
      bottomNavigationBar: ClientBottomNav(
        currentIndex: selectedIndex,
        onDestinationSelected: selectShellTab,
      ),
    );
  }

  void selectShellTab(int index) {
    setState(() => selectedIndex = index);
    if (index != clientShellDependentsTabIndex) return;
    context.read<DependentsCubit>().loadDependents();
  }
}
