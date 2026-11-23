import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/compliance_failure.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/cubit/driver_compliance_cubit.dart';
import 'package:vanep_mobile/modules/driver_professional_data/presentation/cubit/professional_data_cubit.dart';
import 'package:vanep_mobile/modules/driver_professional_data/presentation/pages/professional_data_page.dart';
import 'package:vanep_mobile/modules/profile/data/dtos/profile_summary_dto.dart';
import 'package:vanep_mobile/modules/profile/domain/value_objects/driver_approval_status.dart';

import '../driver_documents/driver_documents_fixture.dart';
import '../driver_documents/presentation/documents_pages_harness.dart';
import '../driver_van_central/driver_van_central_fixtures.dart';
import '../profile/profile_fixtures.dart';

class MockProfessionalDataCubit extends MockCubit<ProfessionalDataState>
    implements ProfessionalDataCubit {}

const approvedDriver = DriverProfileSummaryDto(
  token: 'driver-1',
  rating: 4.9,
  ratingCount: 32,
  experienceYears: 8,
  approvalStatus: DriverApprovalStatus.approved,
  user: testNestedUserDto,
);

void main() {
  late MockProfessionalDataCubit cubit;
  final opened = <String>[];

  setUp(() {
    cubit = MockProfessionalDataCubit();
    opened.clear();
  });

  ProfessionalDataActions actions() => ProfessionalDataActions(
    onOpenServiceAreas: () => opened.add('areas'),
    onOpenPersonalDocuments: () => opened.add('personal'),
    onOpenVanDocuments: () => opened.add('vans'),
    onOpenComingSoon: (title) => opened.add('soon:$title'),
  );

  Future<void> pump(
    WidgetTester tester,
    ProfessionalDataState state, {
    DriverComplianceState? compliance,
  }) async {
    when(() => cubit.state).thenReturn(state);
    tester.view.physicalSize = const Size(1200, 3200);
    tester.view.devicePixelRatio = 1.5;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: VanepTheme.light(),
        locale: const Locale('pt'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: MultiBlocProvider(
          providers: [
            BlocProvider<ProfessionalDataCubit>.value(value: cubit),
            BlocProvider<DriverComplianceCubit>.value(
              value: complianceCubitWith(
                compliance ?? DriverComplianceState.ready(TestCompliance()),
              ),
            ),
          ],
          child: ProfessionalDataPage(actions: actions()),
        ),
      ),
    );
    await tester.pump();
  }

  ProfessionalDataState ready(DriverProfileSummaryDto summary) =>
      ProfessionalDataState(
        status: ProfessionalDataStatus.ready,
        summary: summary,
        attendance: testAttendance,
      );

  testWidgets(
    'the header shows the name, the seal, the rating and experience',
    (tester) async {
      await pump(tester, ready(approvedDriver));

      expect(find.text('Dados profissionais'), findsOneWidget);
      expect(find.text('Ana Motorista'), findsOneWidget);
      expect(find.byIcon(Icons.verified), findsOneWidget);
      expect(find.text('4,9 (32) · 8 anos de experiência'), findsOneWidget);
    },
  );

  testWidgets('under review there is no seal', (tester) async {
    await pump(
      tester,
      ready(
        approvedDriver.copyWith(approvalStatus: DriverApprovalStatus.pending),
      ),
    );

    expect(find.byIcon(Icons.verified), findsNothing);
  });

  testWidgets('without ratings the line shows only the experience', (
    tester,
  ) async {
    await pump(tester, ready(approvedDriver.copyWith(ratingCount: 0)));

    expect(find.text('8 anos de experiência'), findsOneWidget);
  });

  testWidgets('the attendance rows open their screens', (tester) async {
    await pump(tester, ready(approvedDriver));

    await tester.tap(find.text('Áreas de atendimento'));
    await tester.tap(find.text('Expediente'));
    await tester.tap(find.text('Espera no ponto'));
    await tester.tap(find.text('Preço "a partir de"'));

    expect(opened, [
      'areas',
      'soon:Expediente',
      'soon:Espera no ponto',
      'soon:Preço "a partir de"',
    ]);
    expect(find.text('Aceitando novos alunos'), findsOneWidget);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
  });

  testWidgets('the switch changes new students', (tester) async {
    when(() => cubit.setAcceptingStudents(any())).thenAnswer((_) async {});
    await pump(tester, ready(approvedDriver));

    await tester.tap(find.byType(Switch));

    verify(() => cubit.setAcceptingStudents(false)).called(1);
  });

  testWidgets('document rows warn only when something is due', (tester) async {
    await pump(
      tester,
      ready(approvedDriver),
      compliance: DriverComplianceState.ready(
        TestCompliance(
          driverRequirements: [
            rejected(DocumentType.criminalRecord),
            approved(DocumentType.driverLicense),
          ],
          vehicles: [
            TestVehicle(
              token: 'sprinter',
              plate: 'SDF4E21',
              model: 'Sprinter',
              requirements: [
                approved(
                  DocumentType.vehicleInspection,
                  expiresAt: DateTime(2027, 6, 1),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    expect(find.text('1 pendente'), findsOneWidget);
    await tester.tap(find.text('Pessoais'));
    await tester.tap(find.text('Vans'));
    expect(opened, ['personal', 'vans']);
  });

  testWidgets('a failed document situation keeps the rows without warning', (
    tester,
  ) async {
    await pump(
      tester,
      ready(approvedDriver),
      compliance: const DriverComplianceState.failed(ComplianceFailure.network),
    );

    expect(find.text('Pessoais'), findsOneWidget);
    expect(find.text('Vans'), findsOneWidget);
    expect(find.textContaining('pendente'), findsNothing);
  });

  testWidgets('the CNPJ row is optional and coming soon', (tester) async {
    await pump(tester, ready(approvedDriver));

    expect(find.text('CNPJ'), findsOneWidget);
    expect(find.text('Opcional'), findsOneWidget);
    await tester.tap(find.text('CNPJ'));
    expect(opened, ['soon:CNPJ']);
  });

  testWidgets('a failed profile shows the error and retries', (tester) async {
    when(() => cubit.load()).thenAnswer((_) async {});
    await pump(
      tester,
      const ProfessionalDataState(status: ProfessionalDataStatus.failed),
    );

    expect(find.byType(VanepErrorView), findsOneWidget);
    await tester.tap(find.text('Tentar novamente'));
    verify(() => cubit.load()).called(1);
  });
}
