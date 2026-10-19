import 'package:flutter/material.dart';
import 'package:vanep_mobile/core/ui/vanep_feedback.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';

class AssistantRouteGuard extends NavigatorObserver {
  AssistantRouteGuard({
    required this.isAssistant,
    this.onUnauthorized,
  });

  final bool Function() isAssistant;
  final void Function(BuildContext context)? onUnauthorized;

  static const Set<String> restrictedRoutes = {
    '/driver',
    '/proposals',
    '/documents',
    '/search',
    '/client',
  };

  static bool isRestricted(String? routeName) {
    if (routeName == null) return false;
    return restrictedRoutes.contains(routeName);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _guardRoute(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _guardRoute(newRoute);
    }
  }

  void _guardRoute(Route<dynamic> route) {
    if (!isAssistant()) return;
    final name = route.settings.name;
    if (isRestricted(name)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (route.navigator?.canPop() ?? false) {
          route.navigator?.pop();
        }
        final context = route.navigator?.context;
        if (context != null && context.mounted) {
          if (onUnauthorized != null) {
            onUnauthorized!(context);
          } else {
            final l10n = AppLocalizations.of(context);
            if (l10n != null) {
              VanepFeedback.showError(context, l10n.unauthorizedAccess);
            }
          }
        }
      });
    }
  }
}
