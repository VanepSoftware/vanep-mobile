import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/push_notifications/domain/value_objects/push_navigation_target.dart';
import 'package:vanep_mobile/modules/push_notifications/presentation/cubit/push_navigation_cubit.dart';

import '../push_notifications_fixtures.dart';

void main() {
  blocTest<PushNavigationCubit, PushNavigationTarget?>(
    'holds the opened target',
    build: PushNavigationCubit.new,
    act: (cubit) => cubit.openTarget(chatPushTarget),
    expect: () => [chatPushTarget],
  );

  blocTest<PushNavigationCubit, PushNavigationTarget?>(
    'taking the pending target returns it and clears it',
    build: PushNavigationCubit.new,
    seed: () => chatPushTarget,
    act: (cubit) => expect(cubit.takePendingTarget(), chatPushTarget),
    expect: () => [null],
  );

  blocTest<PushNavigationCubit, PushNavigationTarget?>(
    'taking with nothing pending returns null',
    build: PushNavigationCubit.new,
    act: (cubit) => expect(cubit.takePendingTarget(), isNull),
    expect: () => <PushNavigationTarget?>[],
  );

  blocTest<PushNavigationCubit, PushNavigationTarget?>(
    'the same target can open again after it was taken',
    build: PushNavigationCubit.new,
    act: (cubit) => cubit
      ..openTarget(chatPushTarget)
      ..takePendingTarget()
      ..openTarget(chatPushTarget),
    expect: () => [chatPushTarget, null, chatPushTarget],
  );
}
