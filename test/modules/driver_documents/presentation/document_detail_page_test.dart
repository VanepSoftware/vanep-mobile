import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/document_action.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/compliance_state.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_file.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/rejection_reason.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/submission_status.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/cubit/document_file_cubit.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/cubit/driver_compliance_cubit.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/pages/document_detail_page.dart';

import '../driver_documents_fixture.dart';
import 'documents_pages_harness.dart';

class MockDocumentFileCubit extends Mock implements DocumentFileCubit {}

void main() {
  late MockDocumentFileCubit fileCubit;

  setUpAll(
    () =>
        registerFallbackValue(const DocumentFile(mimeType: 'x', sizeBytes: 0)),
  );

  setUp(() {
    fileCubit = MockDocumentFileCubit();
    when(() => fileCubit.state).thenReturn(const DocumentFileState());
    when(() => fileCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => fileCubit.open(any(), any())).thenAnswer((_) async {});
    when(fileCubit.close).thenAnswer((_) async {});
  });

  Future<List<DocumentAction>> pump(
    WidgetTester tester,
    TestCompliance compliance,
    DocumentType type, {
    String? vehicleToken,
  }) async {
    final actions = <DocumentAction>[];
    await tester.pumpWidget(
      documentsHarness(
        complianceCubitWith(DriverComplianceState.ready(compliance)),
        BlocProvider<DocumentFileCubit>.value(
          value: fileCubit,
          child: DocumentDetailPage(
            type: type,
            vehicleToken: vehicleToken,
            onAction: actions.add,
            onOpenImage: (_) {},
          ),
        ),
      ),
    );
    return actions;
  }

  testWidgets('under review shows the sent data and has no action', (
    tester,
  ) async {
    await pump(
      tester,
      TestCompliance(
        driverRequirements: [underReview(DocumentType.schoolDriverCourse)],
      ),
      DocumentType.schoolDriverCourse,
    );

    expect(find.text('Curso especializado'), findsOneWidget);
    expect(find.text('Documento pessoal'), findsOneWidget);
    expect(find.text('Em análise'), findsOneWidget);
    expect(
      find.text(
        'A Vanep confere em até 2 dias úteis. Você recebe a resposta aqui e por e-mail.',
      ),
      findsOneWidget,
    );
    expect(find.text('O que foi enviado'), findsOneWidget);
    expect(find.text('Sobre o documento'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
    expect(find.byType(OutlinedButton), findsNothing);
  });

  testWidgets('a rejected document shows the reason, the message and resend', (
    tester,
  ) async {
    final rejectedCertificate = TestRequirement(
      type: DocumentType.criminalRecord,
      state: ComplianceState.rejected,
      current: TestSubmission(
        status: SubmissionStatus.rejected,
        rejectionReasonCode: RejectionReason.dataMismatch,
        rejectionReason: 'O nome está abreviado',
      ),
    );
    final actions = await pump(
      tester,
      TestCompliance(driverRequirements: [rejectedCertificate]),
      DocumentType.criminalRecord,
    );

    expect(find.text('Dados não conferem com o cadastro'), findsOneWidget);
    expect(find.text('O nome está abreviado'), findsOneWidget);
    expect(find.text('Mensagem da equipe Vanep'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text(
        'O resto do seu cadastro continua valendo. Este documento precisa ser enviado de novo.',
      ),
      200,
    );
    await tester.tap(find.text('Reenviar'));
    expect(actions, [DocumentAction.resend]);
  });

  testWidgets('a rejection without a message has no Vanep mark', (
    tester,
  ) async {
    await pump(
      tester,
      TestCompliance(
        driverRequirements: [rejected(DocumentType.criminalRecord)],
      ),
      DocumentType.criminalRecord,
    );

    expect(find.text('Dados não conferem com o cadastro'), findsOneWidget);
    expect(find.text('Mensagem da equipe Vanep'), findsNothing);
  });

  testWidgets('a renewal under review shows both versions and no action', (
    tester,
  ) async {
    final renewal = TestRequirement(
      type: DocumentType.driverLicense,
      state: ComplianceState.approved,
      satisfied: true,
      current: TestSubmission(
        token: 'cnh-1',
        expiresAt: DateTime(2026, 12, 10),
        cnhCategory: 'D',
      ),
      pending: TestSubmission(
        token: 'cnh-2',
        status: SubmissionStatus.pending,
        cnhCategory: 'D',
      ),
    );
    await pump(
      tester,
      TestCompliance(driverRequirements: [renewal]),
      DocumentType.driverLicense,
    );

    expect(find.text('Nova versão em análise'), findsOneWidget);
    expect(find.text('Versão em vigor'), findsOneWidget);
    expect(find.text('Nova versão'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('an incomplete upload offers to finish it', (tester) async {
    final incomplete = TestRequirement(
      type: DocumentType.criminalRecord,
      state: ComplianceState.pending,
      current: TestSubmission(status: SubmissionStatus.pending, hasFile: false),
    );
    final actions = await pump(
      tester,
      TestCompliance(driverRequirements: [incomplete]),
      DocumentType.criminalRecord,
    );

    expect(find.text('Envio incompleto'), findsOneWidget);
    await tester.tap(find.text('Terminar envio'));
    expect(actions, [DocumentAction.finish]);
  });

  testWidgets('a van document shows its van and opens the file', (
    tester,
  ) async {
    final sprinter = TestVehicle(
      token: 'sprinter',
      plate: 'SDF4E21',
      model: 'Sprinter',
      requirements: [
        approved(
          DocumentType.vehicleInspection,
          expiresAt: DateTime(2026, 11, 29),
        ),
      ],
    );
    final actions = await pump(
      tester,
      TestCompliance(vehicles: [sprinter]),
      DocumentType.vehicleInspection,
      vehicleToken: 'sprinter',
    );

    expect(find.text('Sprinter · SDF4E21'), findsOneWidget);
    expect(find.text('SDF4E21'), findsOneWidget);
    expect(find.text('Vence em 9 dias'), findsOneWidget);
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    await tester.tap(find.text('Ver arquivo'));
    verify(
      () => fileCubit.open('/api/driver-documents/submission-1/file', any()),
    ).called(1);
    await tester.tap(find.text('Enviar nova versão'));
    expect(actions, [DocumentAction.sendNew]);
  });

  testWidgets('not sent shows only what the document is and send', (
    tester,
  ) async {
    final actions = await pump(
      tester,
      TestCompliance(
        driverRequirements: [
          missing(DocumentType.municipalAuthorization, optional: true),
        ],
      ),
      DocumentType.municipalAuthorization,
    );

    expect(find.text('O que foi enviado'), findsNothing);
    expect(
      find.text('Prefeitura ou órgão de trânsito da cidade'),
      findsOneWidget,
    );
    await tester.tap(find.text('Enviar'));
    expect(actions, [DocumentAction.send]);
  });

  testWidgets('a document that left the list says so', (tester) async {
    await pump(
      tester,
      TestCompliance(),
      DocumentType.vehicleInspection,
      vehicleToken: 'gone',
    );

    expect(
      find.text('Este documento não está mais na sua lista.'),
      findsOneWidget,
    );
  });
}
