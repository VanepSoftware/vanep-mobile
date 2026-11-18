import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/core/ui/vanep_secondary_button.dart';
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
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.clientVansTitle,
                              style: context.typography.pageTitle,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.clientVansSubtitle,
                              style: context.typography.cardSubtitle,
                            ),
                          ],
                        ),
                      ),
                      if (state.hasVans)
                        IconButton.outlined(
                          tooltip: l10n.clientVansAddNewVan,
                          onPressed: onSearchTapped,
                          style: IconButton.styleFrom(
                            backgroundColor: context.palette.card,
                            side: BorderSide(color: context.palette.inputBorder),
                          ),
                          icon: Icon(Icons.add, color: context.palette.textPrimary),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Content switch
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
                            if (index > 0) const SizedBox(height: 20),
                            ClientVanCard(
                              van: van,
                              onTap: onVanTapped != null
                                  ? () => onVanTapped!(van)
                                  : null,
                            ),
                          ],
                          const SizedBox(height: 20),
                          VanepSecondaryButton(
                            label: l10n.clientVansAddNewVan,
                            icon: Icons.search_rounded,
                            onPressed: onSearchTapped,
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
