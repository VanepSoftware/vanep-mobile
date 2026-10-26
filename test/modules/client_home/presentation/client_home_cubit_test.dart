import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/client_home/domain/failures/client_home_failure.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/client_home.dart';
import 'package:vanep_mobile/modules/client_home/presentation/cubit/client_home_cubit.dart';
import 'package:vanep_mobile/modules/client_home/presentation/cubit/client_home_state.dart';

import '../client_home_fixtures.dart';
import '../client_home_mocks.dart';

void main() {
  late MockLoadClientHome loadClientHome;

  setUp(() => loadClientHome = MockLoadClientHome());

  ClientHomeCubit buildCubit() =>
      ClientHomeCubit(loadClientHome: loadClientHome);

  void loadReturns(ClientHome home) {
    when(
      loadClientHome.call,
    ).thenAnswer((_) async => Ok<ClientHomeFailure, ClientHome>(home));
  }

  final home = testClientHome();

  blocTest<ClientHomeCubit, ClientHomeState>(
    'loading lands on ready with the home',
    setUp: () => loadReturns(home),
    build: buildCubit,
    act: (cubit) => cubit.loadHome(),
    expect: () => [
      const ClientHomeState(status: ClientHomeStatus.loading),
      ClientHomeState(status: ClientHomeStatus.ready, home: home),
    ],
  );

  blocTest<ClientHomeCubit, ClientHomeState>(
    'a failure is kept for the retry view',
    setUp: () {
      when(loadClientHome.call).thenAnswer(
        (_) async =>
            const Err<ClientHomeFailure, ClientHome>(ClientHomeFailure.network),
      );
    },
    build: buildCubit,
    act: (cubit) => cubit.loadHome(),
    verify: (cubit) {
      expect(cubit.state.hasLoadFailed, isTrue);
      expect(cubit.state.failure, ClientHomeFailure.network);
    },
  );

  blocTest<ClientHomeCubit, ClientHomeState>(
    'reloading keeps the current home visible',
    setUp: () => loadReturns(home),
    build: buildCubit,
    seed: () => ClientHomeState(status: ClientHomeStatus.ready, home: home),
    act: (cubit) => cubit.loadHome(),
    expect: () => <ClientHomeState>[],
  );

  blocTest<ClientHomeCubit, ClientHomeState>(
    'a failed reload keeps the last home instead of the error view',
    setUp: () {
      when(loadClientHome.call).thenAnswer(
        (_) async =>
            const Err<ClientHomeFailure, ClientHome>(ClientHomeFailure.network),
      );
    },
    build: buildCubit,
    seed: () => ClientHomeState(status: ClientHomeStatus.ready, home: home),
    act: (cubit) => cubit.loadHome(),
    verify: (cubit) {
      expect(cubit.state.home, home);
      expect(cubit.state.hasLoadFailed, isFalse);
    },
  );
}
