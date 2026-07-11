import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';
import '../../../../core/ui/vanep_feedback.dart';
import '../../../../core/ui/vanep_gradient_background.dart';
import '../../../../core/ui/vanep_primary_button.dart';
import '../../../../core/ui/vanep_wordmark.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/failures/auth_failure.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'oauth_webview_page.dart';

/// Entry screen: shows the wordmark and a "Continue" button that starts the
/// OAuth login. Reacts to [AuthCubit] to drive the WebView and show feedback.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: VanepGradientBackground(
        child: SafeArea(
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: _onStateChanged,
            builder: (context, state) {
              final busy = state is AuthAuthenticating || state is AuthExchanging;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Spacer(flex: 3),
                    const VanepWordmark(),
                    const SizedBox(height: 16),
                    Text(
                      l10n.welcomeTagline,
                      textAlign: TextAlign.center,
                      style: VanepTypography.tagline.copyWith(
                        color: VanepColors.foreground.withValues(alpha: 0.8),
                      ),
                    ),
                    const Spacer(flex: 4),
                    VanepPrimaryButton(
                      label: l10n.continueButton,
                      isLoading: busy,
                      onPressed: () => context.read<AuthCubit>().startLogin(),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _onStateChanged(BuildContext context, AuthState state) async {
    switch (state) {
      case AuthAuthenticating(:final request):
        final code = await Navigator.of(context).push<String>(
          MaterialPageRoute(
            builder: (_) => OAuthWebViewPage(request: request),
          ),
        );
        if (!context.mounted) return;
        final cubit = context.read<AuthCubit>();
        if (code == null) {
          cubit.cancelLogin();
        } else {
          await cubit.submitAuthorizationCode(code, request);
        }
      case AuthFailureState(:final failure):
        final l10n = AppLocalizations.of(context)!;
        if (failure is CancelledAuthFailure) {
          VanepFeedback.showInfo(context, l10n.loginCancelled);
        } else {
          VanepFeedback.showError(context, l10n.loginFailed);
        }
      default:
        break;
    }
  }
}
