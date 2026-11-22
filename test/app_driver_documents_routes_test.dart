import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/app.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_state.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/document_groups.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_display_state.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/cubit/document_file_cubit.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/cubit/driver_compliance_cubit.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/pages/document_detail_page.dart';

import 'modules/auth/auth_fixtures.dart';
import 'modules/auth/presentation/auth_presentation_mocks.dart';
import 'modules/driver_documents/driver_documents_fixture.dart';
import 'modules/driver_documents/driver_documents_mocks.dart';
import 'modules/driver_documents/presentation/documents_pages_harness.dart';

void main() {
  testWidgets(
    'a pending document opened from the sent screen replaces the flow',
    (tester) async {
      final fileCubit = MockDocumentFileCubit();
      when(() => fileCubit.state).thenReturn(const DocumentFileState());
      when(() => fileCubit.stream).thenAnswer((_) => const Stream.empty());
      when(fileCubit.close).thenAnswer((_) async {});
      getIt.registerFactory<DocumentFileCubit>(() => fileCubit);
      addTearDown(getIt.reset);
      final auth = MockAuthCubit();
      whenListen(
        auth,
        const Stream<AuthState>.empty(),
        initialState: AuthAuthenticated(
          FakeAuthSession(profile: FakeUserProfile(type: UserType.driver)),
        ),
      );
      final criminalRecord = rejected(DocumentType.criminalRecord);
      final compliance = complianceCubitWith(
        DriverComplianceState.ready(
          TestCompliance(driverRequirements: [criminalRecord]),
        ),
      );

      Route<void> fakeRoute(String name, String label, VoidCallback onTap) {
        return MaterialPageRoute<void>(
          settings: RouteSettings(name: name),
          builder: (_) => Scaffold(
            body: TextButton(onPressed: onTap, child: Text(label)),
          ),
        );
      }

      await tester.pumpWidget(
        BlocProvider<AuthCubit>.value(
          value: auth,
          child: documentsHarness(
            compliance,
            Builder(
              builder: (listContext) => TextButton(
                onPressed: () => Navigator.of(listContext).push(
                  fakeRoute(
                    '/driver/documents/detail',
                    'old detail',
                    () => Navigator.of(listContext).push(
                      MaterialPageRoute<void>(
                        settings: const RouteSettings(
                          name: '/driver/documents/submission',
                        ),
                        builder: (sentContext) => Scaffold(
                          body: TextButton(
                            onPressed: () => replaceDocumentFlowWithDetail(
                              sentContext,
                              compliance,
                              DocumentEntry(
                                requirement: criminalRecord,
                                state: const DocumentRejected(),
                              ),
                            ),
                            child: const Text('pending'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                child: const Text('list'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('list'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('old detail'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('pending'));
      await tester.pumpAndSettle();

      expect(find.byType(DocumentDetailPage), findsOneWidget);
      expect(
        tester.widget<DocumentDetailPage>(find.byType(DocumentDetailPage)).type,
        DocumentType.criminalRecord,
      );

      Navigator.of(tester.element(find.byType(DocumentDetailPage))).pop();
      await tester.pumpAndSettle();

      expect(find.text('list'), findsOneWidget);
      expect(find.text('old detail'), findsNothing);
      expect(find.text('pending'), findsNothing);
    },
  );
}
