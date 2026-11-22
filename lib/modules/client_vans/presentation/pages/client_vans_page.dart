import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_vans/domain/entities/client_van.dart';
import 'package:vanep_mobile/modules/client_vans/presentation/cubit/client_vans_cubit.dart';
import 'package:vanep_mobile/modules/client_vans/presentation/cubit/client_vans_state.dart';
import 'package:vanep_mobile/modules/client_vans/presentation/widgets/client_van_card.dart';
import 'package:vanep_mobile/modules/client_vans/presentation/widgets/client_vans_empty_view.dart';
import 'package:vanep_mobile/modules/client_vans/presentation/widgets/client_vans_skeleton.dart';

class ClientVansPage extends StatelessWidget {
  const ClientVansPage({
    required this.onSearchTapped,
    this.onVanTapped,
    this.onChatTapped,
    this.onContractDetailsTapped,
    super.key,
  });

  final VoidCallback onSearchTapped;
  final ValueChanged<ClientVan>? onVanTapped;
  final ValueChanged<ClientVan>? onChatTapped;
  final ValueChanged<ClientVan>? onContractDetailsTapped;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ClientVansCubit>();

    return Scaffold(
      backgroundColor: context.palette.surface,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<ClientVansCubit, ClientVansState>(
          builder: (context, state) {
            return RefreshIndicator(
              color: context.palette.action,
              onRefresh: cubit.refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          l10n.navVans,
                          style: context.typography.pageTitle.copyWith(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      if (state.hasVans)
                        Tooltip(
                          message: l10n.clientVansAddNewVan,
                          child: Material(
                            color: context.palette.card,
                            shape: CircleBorder(
                              side: BorderSide(
                                color: context.palette.inputBorder,
                              ),
                            ),
                            child: InkWell(
                              onTap: onSearchTapped,
                              customBorder: const CircleBorder(),
                              child: SizedBox(
                                width: 38,
                                height: 38,
                                child: Icon(
                                  Icons.search_rounded,
                                  size: 20,
                                  color: context.palette.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  switch (state.status) {
                    ClientVansStatus.loading => const ClientVansSkeleton(),
                    ClientVansStatus.loadFailed => VanepErrorView(
                        message: l10n.clientVansLoadError,
                        retryLabel: l10n.clientVansRetry,
                        onRetry: cubit.loadVans,
                      ),
                    ClientVansStatus.loaded when !state.hasVans =>
                      ClientVansEmptyView(onFindVanTapped: onSearchTapped),
                    ClientVansStatus.loaded => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final (index, van) in state.vans.indexed) ...[
                            if (index > 0) const SizedBox(height: 12),
                            ClientVanCard(
                              van: van,
                              onTap: onVanTapped != null
                                  ? () => onVanTapped!(van)
                                  : null,
                            ),
                          ],
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: _AddAnotherVanButton(
                              label: l10n.clientVansAnotherVanChip,
                              onTap: onSearchTapped,
                            ),
                          ),
                        ],
                      ),
                  },
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AddAnotherVanButton extends StatelessWidget {
  const _AddAnotherVanButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.palette.card,
      shape: StadiumBorder(
        side: BorderSide(color: context.palette.inputBorder),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_rounded,
                size: 16,
                color: context.palette.textPrimary,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: context.palette.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
