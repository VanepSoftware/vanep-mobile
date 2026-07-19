import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/driver.dart';
import '../cubit/drivers_cubit.dart';
import '../cubit/drivers_state.dart';
import 'driver_card.dart';

class DriversHomeBody extends StatelessWidget {
  const DriversHomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<DriversCubit, DriversState>(
      builder: (context, state) {
        return switch (state.status) {
          DriversStatus.initial ||
          DriversStatus.loading => const DriversLoadingIndicator(),
          DriversStatus.error => DriversErrorView(
            message: l10n.driversLoadError,
            retryLabel: l10n.driversRetryButton,
            onRetry: () => context.read<DriversCubit>().loadRecentDrivers(),
          ),
          DriversStatus.loaded => DriversSuggestionsList(
            drivers: state.visibleDrivers,
            emptyMessage: l10n.driversEmpty,
          ),
        };
      },
    );
  }
}

class DriversLoadingIndicator extends StatelessWidget {
  const DriversLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 48),
      child: Center(
        child: CircularProgressIndicator(color: VanepColors.brand),
      ),
    );
  }
}

class DriversErrorView extends StatelessWidget {
  const DriversErrorView({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
    super.key,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: VanepTypography.cardSubtitle,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onRetry,
            child: Text(
              retryLabel,
              style: VanepTypography.ratingLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class DriversSuggestionsList extends StatelessWidget {
  const DriversSuggestionsList({
    required this.drivers,
    required this.emptyMessage,
    super.key,
  });

  final List<Driver> drivers;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (drivers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 48),
        child: Text(
          emptyMessage,
          textAlign: TextAlign.center,
          style: VanepTypography.cardSubtitle,
        ),
      );
    }

    return Column(
      children: [
        for (final driver in drivers)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DriverCard(driver: driver),
          ),
      ],
    );
  }
}
