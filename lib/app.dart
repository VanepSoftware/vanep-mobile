import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/design_system/vanep_theme.dart';
import 'core/di/service_locator.dart';
import 'core/ui/vanep_gradient_background.dart';
import 'core/ui/vanep_wordmark.dart';
import 'l10n/app_localizations.dart';
import 'modules/auth/presentation/cubit/auth_cubit.dart';
import 'modules/auth/presentation/cubit/auth_state.dart';
import 'modules/auth/presentation/pages/home_page.dart';
import 'modules/auth/presentation/pages/welcome_page.dart';

class VanepApp extends StatelessWidget {
  const VanepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      theme: VanepTheme.dark(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<AuthCubit>(
        create: (_) => getIt<AuthCubit>()..checkSession(),
        child: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return switch (state) {
          AuthUnknown() => const SplashScreen(),
          AuthAuthenticated(:final session) => HomePage(
            profile: session.profile,
          ),
          _ => const WelcomePage(),
        };
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: VanepGradientBackground(child: Center(child: VanepWordmark())),
    );
  }
}
