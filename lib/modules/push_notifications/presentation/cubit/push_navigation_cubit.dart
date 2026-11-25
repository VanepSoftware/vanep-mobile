import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/modules/push_notifications/domain/value_objects/push_navigation_target.dart';

/// Holds the target of a tapped notification until a shell can open it, so a
/// tap that arrives before sign-in (cold start) is not lost.
class PushNavigationCubit extends Cubit<PushNavigationTarget?> {
  PushNavigationCubit() : super(null);

  void openTarget(PushNavigationTarget target) => emit(target);

  PushNavigationTarget? takePendingTarget() {
    final target = state;
    if (target != null) emit(null);
    return target;
  }
}
