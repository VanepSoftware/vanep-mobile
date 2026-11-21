import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/compliance_failure.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/load_my_compliance.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/cubit/driver_compliance_cubit.dart';

import '../driver_documents_fixture.dart';
import '../driver_documents_mocks.dart';

void main() {
  late MockDriverComplianceRepository repository;
  final compliance = TestCompliance();

  setUp(() => repository = MockDriverComplianceRepository());

  DriverComplianceCubit build() =>
      DriverComplianceCubit(loadMyCompliance: LoadMyCompliance(repository));

  blocTest<DriverComplianceCubit, DriverComplianceState>(
    'loading ends with the situation of the back',
    setUp: () =>
        when(repository.loadMine).thenAnswer((_) async => Ok(compliance)),
    build: build,
    act: (cubit) => cubit.load(),
    expect: () => [
      const DriverComplianceState.loading(),
      DriverComplianceState.ready(compliance),
    ],
  );

  blocTest<DriverComplianceCubit, DriverComplianceState>(
    'a failed load shows the failure',
    setUp: () =>
        when(repository.loadMine)
            .thenAnswer((_) async => const Err(ComplianceFailure.network)),
    build: build,
    act: (cubit) => cubit.load(),
    expect: () => const [
      DriverComplianceState.loading(),
      DriverComplianceState.failed(ComplianceFailure.network),
    ],
  );

  blocTest<DriverComplianceCubit, DriverComplianceState>(
    'a refresh keeps the screen and swaps the situation',
    setUp: () =>
        when(repository.loadMine).thenAnswer((_) async => Ok(compliance)),
    build: build,
    seed: () => DriverComplianceState.ready(TestCompliance()),
    act: (cubit) => cubit.refresh(),
    expect: () => [DriverComplianceState.ready(compliance)],
  );

  blocTest<DriverComplianceCubit, DriverComplianceState>(
    'a failed refresh keeps the situation already on screen',
    setUp: () =>
        when(repository.loadMine)
            .thenAnswer((_) async => const Err(ComplianceFailure.network)),
    build: build,
    seed: () => DriverComplianceState.ready(compliance),
    act: (cubit) => cubit.refresh(),
    expect: () => const <DriverComplianceState>[],
  );
}
