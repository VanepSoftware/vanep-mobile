import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/modules/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:vanep_mobile/modules/notifications/presentation/cubit/notifications_state.dart';

class MockNotificationsCubit extends MockCubit<NotificationsState>
    implements NotificationsCubit {}

/// Registers an idle notifications cubit in [getIt] for the current test, so
/// widgets that open the notifications page can be pumped.
MockNotificationsCubit registerNotificationsCubitDouble() {
  final cubit = MockNotificationsCubit();
  when(() => cubit.state)
      .thenReturn(const NotificationsState(status: NotificationsStatus.loaded));
  when(cubit.load).thenAnswer((_) async {});
  getIt.registerFactory<NotificationsCubit>(() => cubit);
  addTearDown(() => getIt.unregister<NotificationsCubit>());
  return cubit;
}
