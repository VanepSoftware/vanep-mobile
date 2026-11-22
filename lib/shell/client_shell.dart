import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/core/ui/vanep_feedback.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/user_profile.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/personal_data_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/pages/personal_address_form_page.dart';
import 'package:vanep_mobile/modules/client_home/presentation/cubit/client_home_cubit.dart';
import 'package:vanep_mobile/modules/client_home/presentation/pages/client_home_tab.dart';
import 'package:vanep_mobile/modules/client_vans/domain/entities/client_van.dart';
import 'package:vanep_mobile/modules/client_vans/presentation/cubit/client_vans_cubit.dart';
import 'package:vanep_mobile/modules/client_vans/presentation/helpers/client_van_chat_launcher.dart';
import 'package:vanep_mobile/modules/client_vans/presentation/pages/client_van_detail_page.dart';
import 'package:vanep_mobile/modules/client_vans/presentation/pages/client_vans_page.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/conversations_inbox_cubit.dart';
import 'package:vanep_mobile/modules/conversations/presentation/pages/conversations_inbox_tab.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependents_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependents_state.dart';
import 'package:vanep_mobile/modules/dependents/presentation/pages/dependent_detail_page.dart';
import 'package:vanep_mobile/modules/dependents/presentation/pages/dependents_page.dart';
import 'package:vanep_mobile/shell/client_bottom_nav.dart';
import 'package:vanep_mobile/shell/shell_account_drawer.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

const clientShellHomeTabIndex = 0;

const clientShellVansTabIndex = 1;

const clientShellConversationsTabIndex = 2;

const clientShellDependentsTabIndex = 3;

class ClientShell extends StatefulWidget {
  const ClientShell({
    required this.profile,
    required this.openDriverSearch,
    required this.openDriverProfile,
    required this.openConversationChat,
    required this.openClientProposals,
    required this.openProposalDetail,
    required this.openNegotiationChat,
    super.key,
  });

  final UserProfile profile;

  final Future<void> Function(BuildContext context) openDriverSearch;

  final Future<void> Function(BuildContext context, String driverToken)
  openDriverProfile;

  final Future<void> Function(BuildContext context, Conversation conversation)
  openConversationChat;

  final Future<void> Function(BuildContext context) openClientProposals;

  final Future<void> Function(
    BuildContext context,
    ClientServiceRequest request,
  )
  openProposalDetail;

  final Future<void> Function(
    BuildContext context,
    ClientServiceRequest request,
  )
  openNegotiationChat;

  @override
  State<ClientShell> createState() => ClientShellState();
}

class ClientShellState extends State<ClientShell> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final displayName = widget.profile.name ?? widget.profile.email ?? '';

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: context.palette.surface,
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
            onAddAddressTapped: () => openAddressFormFromHome(context),
            onAddDependentTapped: () =>
                selectShellTab(clientShellDependentsTabIndex),
            onProposalsTapped: () => widget.openClientProposals(context),
            onProposalTapped: (request) =>
                openProposalAndReloadHome(context, request),
            onNegotiationChatTapped: (request) =>
                widget.openNegotiationChat(context, request),
          ),
          ClientVansPage(
            onSearchTapped: () => widget.openDriverSearch(context),
            onVanTapped: (van) => openClientVanDetail(
              context,
              van: van,
              onChatWithDriver: () => _openChatWithDriver(van),
              onDependentTapped: _openDependentProfileFromVan,
            ),
            onChatTapped: _openChatWithDriver,
          ),
          ConversationsInboxTab(
            viewerSide: ConversationParticipant.client,
            onConversationTapped: (conversation) =>
                widget.openConversationChat(context, conversation),
          ),
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
    if (index == clientShellHomeTabIndex) {
      context.read<ClientHomeCubit>().loadHome();
    }
    if (index == clientShellVansTabIndex) {
      context.read<ClientVansCubit>().loadVans();
    }
    if (index == clientShellConversationsTabIndex) {
      context.read<ConversationsInboxCubit>().loadConversations();
    }
    if (index == clientShellDependentsTabIndex) {
      context.read<DependentsCubit>().loadDependents();
    }
  }

  Future<void> openProposalAndReloadHome(
    BuildContext context,
    ClientServiceRequest request,
  ) async {
    final homeCubit = context.read<ClientHomeCubit>();
    await widget.openProposalDetail(context, request);
    await homeCubit.loadHome();
  }

  Future<void> openAddressFormFromHome(BuildContext context) async {
    final syncProfile = context.read<AuthCubit>().syncProfile;
    final homeCubit = context.read<ClientHomeCubit>();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider<PersonalDataCubit>(
          create: (_) => getIt<PersonalDataCubit>(param1: syncProfile)..load(),
          child: const PersonalAddressFormPage(),
        ),
      ),
    );
    await homeCubit.loadHome();
  }

  Future<void> _openChatWithDriver(ClientVan van) async {
    final target = await resolveConversationForClientVan(context, van);
    if (!mounted) return;
    if (target == null) {
      final l10n = AppLocalizations.of(context)!;
      VanepFeedback.showInfo(context, l10n.clientVansNoConversationYet);
      return;
    }
    await widget.openConversationChat(context, target);
  }

  Future<void> _openDependentProfileFromVan(ClientVanDependent vanDep) async {
    final dependentsCubit = context.read<DependentsCubit>();
    if (dependentsCubit.state.status != DependentsStatus.ready ||
        _findMatchingDependent(dependentsCubit.state.dependents, vanDep) ==
            null) {
      await dependentsCubit.loadDependents();
    }
    if (!mounted) return;

    final match = _findMatchingDependent(
      dependentsCubit.state.dependents,
      vanDep,
    );

    if (match == null) {
      final l10n = AppLocalizations.of(context)!;
      VanepFeedback.showInfo(
        context,
        l10n.clientVanDependentNotInList(vanDep.name),
      );
      return;
    }

    Navigator.of(context).popUntil((route) => route.isFirst);
    selectShellTab(clientShellDependentsTabIndex);
    await openDependentDetail(context, match.token);
  }

  Dependent? _findMatchingDependent(
    List<Dependent> dependents,
    ClientVanDependent vanDep,
  ) {
    final targetName = vanDep.name.trim().toLowerCase();
    for (final dep in dependents) {
      if (dep.token == vanDep.token ||
          dep.name.trim().toLowerCase() == targetName) {
        return dep;
      }
    }
    return null;
  }
}
