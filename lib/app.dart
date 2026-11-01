import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/core/network/api_image_loader.dart';
import 'package:vanep_mobile/core/ui/vanep_brand_splash.dart';
import 'package:vanep_mobile/core/ui/vanep_coming_soon_page.dart';
import 'package:vanep_mobile/core/ui/vanep_intro_gate.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_state.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/login_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/pages/login_page.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/presentation/formatters/conversation_labels.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/chat_cubit.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/conversations_inbox_cubit.dart';
import 'package:vanep_mobile/modules/client_home/presentation/cubit/client_home_cubit.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/client_proposals_cubit.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/pages/client_proposals_page.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/conversations/presentation/pages/chat_page.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependents_cubit.dart';
import 'package:vanep_mobile/modules/driver/presentation/cubit/driver_home_cubit.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_controller.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/driver_profile_cubit.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/drivers_cubit.dart';
import 'package:vanep_mobile/modules/drivers/presentation/pages/driver_profile_page.dart';
import 'package:vanep_mobile/modules/driver_search/presentation/cubit/driver_search_cubit.dart';
import 'package:vanep_mobile/modules/driver_search/presentation/pages/driver_search_page.dart';
import 'package:vanep_mobile/modules/driver_service_areas/presentation/cubit/driver_service_areas_cubit.dart';
import 'package:vanep_mobile/modules/driver_service_areas/presentation/pages/driver_service_areas_page.dart';
import 'package:vanep_mobile/modules/driver_vans/presentation/cubit/driver_vans_cubit.dart';
import 'package:vanep_mobile/modules/driver_van_central/presentation/cubit/van_central_cubit.dart';
import 'package:vanep_mobile/modules/driver_vans/presentation/pages/driver_van_registration_page.dart';
import 'package:vanep_mobile/modules/driver_vans/presentation/pages/driver_vans_page.dart';
import 'package:vanep_mobile/modules/profile/presentation/cubit/profile_summary_cubit.dart';
import 'package:vanep_mobile/shell/client_shell.dart';
import 'package:vanep_mobile/shell/driver_shell.dart';

class VanepApp extends StatelessWidget {
  const VanepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<ApiImageLoader>.value(
      value: getIt<ApiImageLoader>(),
      child: BlocProvider<AuthCubit>(
        create: (_) => getIt<AuthCubit>()..checkSession(),
        child: MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          debugShowCheckedModeBanner: false,
          theme: VanepTheme.light(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const VanepIntroGate(child: AuthGate()),
        ),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          current is AuthAuthenticated && previous is! AuthAuthenticated,
      listener: (context, _) =>
          Navigator.of(context).popUntil((route) => route.isFirst),
      builder: (context, state) {
        return switch (state) {
          AuthUnknown() => const SplashScreen(),
          AuthAuthenticated(:final session) => switch (session.profile.type) {
            UserType.driver => MultiBlocProvider(
              providers: [
                BlocProvider<DriverHomeCubit>(
                  create: (_) => getIt<DriverHomeCubit>(),
                ),
                BlocProvider<ProfileSummaryCubit>(
                  create: (_) => getIt<ProfileSummaryCubit>(),
                ),
                BlocProvider<ConversationsInboxCubit>(
                  create: (_) => getIt<ConversationsInboxCubit>(),
                ),
                BlocProvider<VanCentralCubit>(
                  create: (_) => getIt<VanCentralCubit>()..load(),
                ),
              ],
              child: DriverShell(
                profile: session.profile,
                openServiceAreas: openDriverServiceAreas,
                openMyVans: openDriverVans,
                openVanRegistration: openDriverVanRegistration,
                openConversationChat: (context, conversation) =>
                    openInboxConversation(
                      context,
                      conversation,
                      viewerSide: ConversationParticipant.driver,
                    ),
              ),
            ),
            _ => MultiBlocProvider(
              providers: [
                BlocProvider<DriversCubit>(
                  create: (_) => getIt<DriversCubit>()..loadRecentDrivers(),
                ),
                BlocProvider<ProfileSummaryCubit>(
                  create: (_) => getIt<ProfileSummaryCubit>(),
                ),
                BlocProvider<DriverSearchCubit>(
                  create: (_) => getIt<DriverSearchCubit>(),
                ),
                BlocProvider<DependentsCubit>(
                  create: (_) => getIt<DependentsCubit>(),
                ),
                BlocProvider<ConversationsInboxCubit>(
                  create: (_) => getIt<ConversationsInboxCubit>(),
                ),
                BlocProvider<ClientHomeCubit>(
                  create: (_) => getIt<ClientHomeCubit>()..loadHome(),
                ),
              ],
              child: ClientShell(
                profile: session.profile,
                openDriverSearch: openDriverSearch,
                openDriverProfile: openDriverProfile,
                openConversationChat: (context, conversation) =>
                    openInboxConversation(
                      context,
                      conversation,
                      viewerSide: ConversationParticipant.client,
                    ),
                openClientProposals: openClientProposals,
              ),
            ),
          },
          _ => BlocProvider<LoginCubit>(
            create: (context) => getIt<LoginCubit>(
              param1: context.read<AuthCubit>().startSession,
            ),
            child: const LoginPage(),
          ),
        };
      },
    );
  }
}

Future<void> openDriverSearch(BuildContext context) async {
  final autocomplete = getIt<PlaceAutocompleteController>();
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider<DriverSearchCubit>(
        create: (_) => getIt<DriverSearchCubit>(),
        child: DriverSearchPage(
          autocomplete: autocomplete,
          onDriverSelected: (driverToken) =>
              openDriverProfile(context, driverToken),
        ),
      ),
    ),
  );
  autocomplete.dispose();
}

Route<void> clientProposalsRoute(BuildContext context) {
  return MaterialPageRoute<void>(
    builder: (_) => BlocProvider<ClientProposalsCubit>(
      create: (_) => getIt<ClientProposalsCubit>()..loadProposals(),
      child: ClientProposalsPage(
        actions: ClientProposalsActions(
          onSearchVansTapped: () => openDriverSearch(context),
          onSeeProposal: (_) => openComingSoonPage(
            context,
            title: AppLocalizations.of(context)!.clientProposalsSeeProposal,
            message: AppLocalizations.of(context)!.comingSoon,
          ),
          onSeeRequest: (_) => openComingSoonPage(
            context,
            title: AppLocalizations.of(context)!.clientProposalsSeeRequest,
            message: AppLocalizations.of(context)!.comingSoon,
          ),
          onChat: (request) => openClientNegotiationChat(context, request),
        ),
      ),
    ),
  );
}

Future<void> openClientProposals(BuildContext context) {
  return Navigator.of(context).push(clientProposalsRoute(context));
}

Future<void> openDriverProfile(BuildContext context, String driverToken) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider<DriverProfileCubit>(
        create: (_) =>
            getIt<DriverProfileCubit>(param1: driverToken)..loadProfile(),
        child: const DriverProfilePage(),
      ),
    ),
  );
}

Future<void> openInboxConversation(
  BuildContext context,
  Conversation conversation, {
  required ConversationParticipant viewerSide,
}) {
  return openConversationChat(
    context,
    conversationToken: conversation.token,
    counterpartName: conversationCounterpartName(conversation, viewerSide),
    viewerSide: viewerSide,
  );
}

Future<void> openConversationChat(
  BuildContext context, {
  required String conversationToken,
  required String counterpartName,
  required ConversationParticipant viewerSide,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider<ChatCubit>(
        create: (_) => getIt<ChatCubit>(param1: conversationToken)..start(),
        child: ChatPage(
          counterpartName: counterpartName,
          viewerSide: viewerSide,
        ),
      ),
    ),
  );
}

Future<void> openClientNegotiationChat(
  BuildContext context,
  ClientServiceRequest request,
) async {
  final conversationToken = request.conversationToken;
  if (conversationToken == null) return;
  await openConversationChat(
    context,
    conversationToken: conversationToken,
    counterpartName: request.driverName,
    viewerSide: ConversationParticipant.client,
  );
}

Future<void> openDriverVans(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider<DriverVansCubit>(
        create: (_) => getIt<DriverVansCubit>()..loadVans(),
        child: const DriverVansPage(),
      ),
    ),
  );
}

Future<void> openDriverVanRegistration(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider<DriverVansCubit>(
        create: (_) => getIt<DriverVansCubit>()..loadVans(),
        child: const DriverVanRegistrationPage(),
      ),
    ),
  );
}

Future<void> openDriverServiceAreas(BuildContext context) async {
  final autocomplete = getIt<PlaceAutocompleteController>();
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider<DriverServiceAreasCubit>(
        create: (_) => getIt<DriverServiceAreasCubit>()..loadMyAreas(),
        child: DriverServiceAreasPage(autocomplete: autocomplete),
      ),
    ),
  );
  autocomplete.dispose();
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const VanepBrandSplash();
  }
}
