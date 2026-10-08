import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/core/network/api_image_loader.dart';
import 'package:vanep_mobile/core/ui/vanep_wordmark.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_state.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/login_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/pages/login_page.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';
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
          home: const AuthGate(),
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
              ],
              child: DriverShell(
                profile: session.profile,
                openServiceAreas: openDriverServiceAreas,
                openMyVans: openDriverVans,
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
              ],
              child: ClientShell(
                profile: session.profile,
                openDriverSearch: openDriverSearch,
                openDriverProfile: openDriverProfile,
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
    return const Scaffold(
      backgroundColor: VanepColors.card,
      body: Center(child: VanepWordmark()),
    );
  }
}
