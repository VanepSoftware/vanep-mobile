import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/user_profile.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/personal_data_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/pages/personal_address_form_page.dart';
import 'package:vanep_mobile/modules/client_home/presentation/cubit/client_home_cubit.dart';
import 'package:vanep_mobile/modules/client_home/presentation/pages/client_home_tab.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/conversations_inbox_cubit.dart';
import 'package:vanep_mobile/modules/conversations/presentation/pages/conversations_inbox_tab.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependents_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/pages/dependents_page.dart';
import 'package:vanep_mobile/modules/drivers/presentation/pages/find_vans_tab.dart';
import 'package:vanep_mobile/shell/client_bottom_nav.dart';
import 'package:vanep_mobile/shell/shell_account_drawer.dart';

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
    super.key,
  });

  final UserProfile profile;

  final Future<void> Function(BuildContext context) openDriverSearch;

  final Future<void> Function(BuildContext context, String driverToken)
  openDriverProfile;

  final Future<void> Function(BuildContext context, Conversation conversation)
  openConversationChat;

  final Future<void> Function(BuildContext context) openClientProposals;

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
            onAddAddressTapped: () => openAddressFormFromHome(context),
            onAddDependentTapped: () =>
                selectShellTab(clientShellDependentsTabIndex),
            onProposalsTapped: () => widget.openClientProposals(context),
          ),
          FindVansTab(
            onSearchTapped: () => widget.openDriverSearch(context),
            onDriverSelected: (driverToken) =>
                widget.openDriverProfile(context, driverToken),
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
    if (index == clientShellConversationsTabIndex) {
      context.read<ConversationsInboxCubit>().loadConversations();
    }
    if (index == clientShellDependentsTabIndex) {
      context.read<DependentsCubit>().loadDependents();
    }
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
}
