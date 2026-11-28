import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/ui/vanep_coming_soon.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/notifications/domain/entities/app_notification.dart';
import 'package:vanep_mobile/modules/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:vanep_mobile/modules/notifications/presentation/cubit/notifications_state.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        final cubit = context.read<NotificationsCubit>();
        return Scaffold(
          backgroundColor: context.palette.surface,
          appBar: AppBar(title: Text(l10n.navNotifications)),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Below the app bar: beside the title it cuts it on narrow screens.
              if (state.hasUnread)
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextButton(
                      onPressed: cubit.markAllRead,
                      child: Text(l10n.notificationsMarkAllRead),
                    ),
                  ),
                ),
              Expanded(
                child: switch (state.status) {
                  NotificationsStatus.loading => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  NotificationsStatus.loadFailed => VanepErrorView(
                    message: l10n.notificationsLoadError,
                    retryLabel: l10n.notificationsRetry,
                    onRetry: cubit.load,
                  ),
                  NotificationsStatus.loaded when state.items.isEmpty =>
                    VanepComingSoon(
                      title: l10n.notificationsEmptyTitle,
                      message: l10n.notificationsEmptyMessage,
                    ),
                  NotificationsStatus.loaded => _NotificationsList(
                    state: state,
                  ),
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NotificationsList extends StatelessWidget {
  const _NotificationsList({required this.state});

  final NotificationsState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NotificationsCubit>();
    final showFooter = state.hasMore;

    return RefreshIndicator(
      onRefresh: cubit.refresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.extentAfter < 200) cubit.loadMore();
          return false;
        },
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: state.items.length + (showFooter ? 1 : 0),
          separatorBuilder: (_, _) =>
              Divider(height: 1, color: context.palette.divider),
          itemBuilder: (context, index) {
            if (index >= state.items.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final item = state.items[index];
            return NotificationTile(
              notification: item,
              onTap: () => cubit.markRead(item.token),
            );
          },
        ),
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    required this.notification,
    required this.onTap,
    super.key,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final unread = notification.isUnread;

    return Material(
      color: unread ? context.palette.actionSurface : context.palette.card,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6, right: 12),
                child: Icon(
                  Icons.circle,
                  size: 8,
                  color: unread ? context.palette.action : Colors.transparent,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: context.typography.cardTitle,
                    ),
                    if (notification.body.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: context.typography.cardSubtitle,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      DateFormat.yMd(locale)
                          .add_Hm()
                          .format(notification.createdAt),
                      style: context.typography.cardSubtitle.copyWith(
                        color: context.palette.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
