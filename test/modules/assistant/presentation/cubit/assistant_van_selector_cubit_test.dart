import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_van_selector_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_van_selector_state.dart';

import '../../fixtures/assistant_fixtures.dart';
import '../../mocks/assistant_mocks.dart';

void main() {
  late MockGetLinkedVans mockGetLinkedVans;

  setUp(() {
    mockGetLinkedVans = MockGetLinkedVans();
  });

  group('AssistantVanSelectorCubit', () {
    test('initial state has isLoading=false, empty vans, and null selection', () {
      final cubit = AssistantVanSelectorCubit(
        getLinkedVans: mockGetLinkedVans,
      );

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.vans, isEmpty);
      expect(cubit.state.selectedVan, isNull);
      expect(cubit.state.failure, isNull);
      expect(cubit.state.hasMultipleVans, isFalse);
      expect(cubit.state.hasActiveVan, isFalse);
    });

    blocTest<AssistantVanSelectorCubit, AssistantVanSelectorState>(
      'loadVans emits loading and selects the single van when exactly one is returned',
      build: () {
        when(() => mockGetLinkedVans()).thenAnswer(
          (_) async => const Ok([testAssistantVanPrimary]),
        );
        return AssistantVanSelectorCubit(getLinkedVans: mockGetLinkedVans);
      },
      act: (cubit) => cubit.loadVans(),
      expect: () => [
        const AssistantVanSelectorState(isLoading: true),
        const AssistantVanSelectorState(
          isLoading: false,
          vans: [testAssistantVanPrimary],
          selectedVan: testAssistantVanPrimary,
        ),
      ],
      verify: (_) => verify(() => mockGetLinkedVans()).called(1),
    );

    blocTest<AssistantVanSelectorCubit, AssistantVanSelectorState>(
      'loadVans emits loading and selects first van when multiple are returned',
      build: () {
        when(() => mockGetLinkedVans()).thenAnswer(
          (_) async => const Ok([
            testAssistantVanPrimary,
            testAssistantVanSecondary,
          ]),
        );
        return AssistantVanSelectorCubit(getLinkedVans: mockGetLinkedVans);
      },
      act: (cubit) => cubit.loadVans(),
      expect: () => [
        const AssistantVanSelectorState(isLoading: true),
        const AssistantVanSelectorState(
          isLoading: false,
          vans: [
            testAssistantVanPrimary,
            testAssistantVanSecondary,
          ],
          selectedVan: testAssistantVanPrimary,
        ),
      ],
    );

    blocTest<AssistantVanSelectorCubit, AssistantVanSelectorState>(
      'loadVans preserves existing selectedVan if still present in returned list',
      build: () {
        when(() => mockGetLinkedVans()).thenAnswer(
          (_) async => const Ok([
            testAssistantVanPrimary,
            testAssistantVanSecondary,
          ]),
        );
        return AssistantVanSelectorCubit(getLinkedVans: mockGetLinkedVans);
      },
      seed: () => const AssistantVanSelectorState(
        selectedVan: testAssistantVanSecondary,
      ),
      act: (cubit) => cubit.loadVans(),
      expect: () => [
        const AssistantVanSelectorState(
          isLoading: true,
          selectedVan: testAssistantVanSecondary,
        ),
        const AssistantVanSelectorState(
          isLoading: false,
          vans: [
            testAssistantVanPrimary,
            testAssistantVanSecondary,
          ],
          selectedVan: testAssistantVanSecondary,
        ),
      ],
    );

    blocTest<AssistantVanSelectorCubit, AssistantVanSelectorState>(
      'loadVans emits empty list and null selectedVan when backend returns empty list',
      build: () {
        when(() => mockGetLinkedVans()).thenAnswer(
          (_) async => const Ok([]),
        );
        return AssistantVanSelectorCubit(getLinkedVans: mockGetLinkedVans);
      },
      act: (cubit) => cubit.loadVans(),
      expect: () => [
        const AssistantVanSelectorState(isLoading: true),
        const AssistantVanSelectorState(
          isLoading: false,
          vans: [],
          selectedVan: null,
        ),
      ],
    );

    blocTest<AssistantVanSelectorCubit, AssistantVanSelectorState>(
      'loadVans emits failure when usecase fails',
      build: () {
        when(() => mockGetLinkedVans()).thenAnswer(
          (_) async => const Err(AssistantFailure.network),
        );
        return AssistantVanSelectorCubit(getLinkedVans: mockGetLinkedVans);
      },
      act: (cubit) => cubit.loadVans(),
      expect: () => [
        const AssistantVanSelectorState(isLoading: true),
        const AssistantVanSelectorState(
          isLoading: false,
          failure: AssistantFailure.network,
        ),
      ],
    );

    blocTest<AssistantVanSelectorCubit, AssistantVanSelectorState>(
      'selectVan updates the selectedVan in state',
      build: () => AssistantVanSelectorCubit(getLinkedVans: mockGetLinkedVans),
      seed: () => const AssistantVanSelectorState(
        vans: [testAssistantVanPrimary, testAssistantVanSecondary],
        selectedVan: testAssistantVanPrimary,
      ),
      act: (cubit) => cubit.selectVan(testAssistantVanSecondary),
      expect: () => [
        const AssistantVanSelectorState(
          vans: [testAssistantVanPrimary, testAssistantVanSecondary],
          selectedVan: testAssistantVanSecondary,
        ),
      ],
    );
  });
}
