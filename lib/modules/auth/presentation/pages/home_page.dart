import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';
import '../../../../core/ui/vanep_gradient_background.dart';
import '../../../../core/ui/vanep_primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/user_profile.dart';
import '../cubit/auth_cubit.dart';

/// Minimal authenticated landing: greets the user and offers sign-out.
class HomePage extends StatelessWidget {
  const HomePage({required this.profile, super.key});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final name = profile.name ?? profile.email ?? '';

    return Scaffold(
      body: VanepGradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.homeGreeting(name), style: VanepTypography.heading),
                if (profile.email != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.homeSignedInAs(profile.email!),
                    style: VanepTypography.body.copyWith(
                      color: VanepColors.foreground.withValues(alpha: 0.75),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                VanepPrimaryButton(
                  label: l10n.signOutButton,
                  onPressed: () => context.read<AuthCubit>().signOut(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
