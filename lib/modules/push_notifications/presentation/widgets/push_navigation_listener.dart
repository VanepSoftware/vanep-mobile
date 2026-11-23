import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/modules/push_notifications/domain/value_objects/push_navigation_target.dart';
import 'package:vanep_mobile/modules/push_notifications/presentation/cubit/push_navigation_cubit.dart';

typedef PushTargetOpener = Future<void> Function(
  BuildContext context,
  PushNavigationTarget target,
);

class PushNavigationListener extends StatefulWidget {
  const PushNavigationListener({
    required this.openTarget,
    required this.child,
    super.key,
  });

  final PushTargetOpener openTarget;

  final Widget child;

  @override
  State<PushNavigationListener> createState() => PushNavigationListenerState();
}

class PushNavigationListenerState extends State<PushNavigationListener> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => openPendingTarget());
  }

  void openPendingTarget() {
    if (!mounted) return;
    final target = context.read<PushNavigationCubit>().takePendingTarget();
    if (target != null) widget.openTarget(context, target);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PushNavigationCubit, PushNavigationTarget?>(
      listenWhen: (_, current) => current != null,
      listener: (_, _) => openPendingTarget(),
      child: widget.child,
    );
  }
}
