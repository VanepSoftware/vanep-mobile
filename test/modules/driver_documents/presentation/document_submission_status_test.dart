import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/media/document_source.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/document_submission_failure.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/submit_document.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/cubit/document_submission_cubit.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/cubit/driver_compliance_cubit.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/pages/document_submission_status_view.dart';

import '../../../core/media/media_mocks.dart';
import '../driver_documents_fixture.dart';
import '../driver_documents_mocks.dart';
import 'documents_pages_harness.dart';

void main() {
  late MockDocumentCapture capture;
  late DocumentSubmissionCubit cubit;

  setUpAll(() => registerFallbackValue(DocumentSource.scanner));

  setUp(() {
    capture = MockDocumentCapture();
    final submissions = MockDocumentSubmissionRepository();
    cubit = DocumentSubmissionCubit(
      type: DocumentType.schoolVehicleAuthorization,
      documentCapture: capture,
      submitDocument: SubmitDocument(submissions),
    );
  });

  tearDown(() => cubit.close());

  Widget host(Widget child, {TestCompliance? compliance}) => documentsHarness(
    complianceCubitWith(
      DriverComplianceState.ready(compliance ?? TestCompliance()),
    ),
    BlocProvider<DocumentSubmissionCubit>.value(value: cubit, child: child),
  );

  group('sending and sent (M6)', () {
    Future<void> pumpStatus(
      WidgetTester tester,
      DocumentSubmissionState state, {
      TestCompliance? compliance,
      VoidCallback? onBack,
      OpenPendingDocument? onOpenPending,
    }) {
      return tester.pumpWidget(
        host(
          DocumentSubmissionStatusView(
            state: state,
            vehicleCaption: 'Sprinter · SDF4E21',
            onBackToDocuments: onBack ?? () {},
            onOpenPending: onOpenPending ?? (_, _) {},
          ),
          compliance: compliance,
        ),
      );
    }

    testWidgets('sending shows the progress of the file', (tester) async {
      await pumpStatus(
        tester,
        cubit.state.copyWith(
          step: SubmissionStep.sending,
          sentBytes: 943718,
          totalBytes: 1468006,
        ),
      );

      expect(find.text('Enviando…'), findsOneWidget);
      expect(
        find.text('Autorização escolar · Sprinter · SDF4E21'),
        findsOneWidget,
      );
      expect(find.text('0,9 de 1,4 MB'), findsOneWidget);
      expect(find.text('64%'), findsOneWidget);
      expect(find.text('Mantenha o app aberto até terminar.'), findsOneWidget);
    });

    testWidgets('sent lists what is still missing and goes back', (
      tester,
    ) async {
      var wentBack = false;
      await pumpStatus(
        tester,
        cubit.state.copyWith(step: SubmissionStep.sent),
        compliance: TestCompliance(
          driverRequirements: [rejected(DocumentType.criminalRecord)],
        ),
        onBack: () => wentBack = true,
      );

      expect(find.text('Documento enviado'), findsOneWidget);
      expect(find.text('Pendências'), findsOneWidget);
      expect(find.text('Certidão criminal'), findsOneWidget);
      expect(find.text('Reprovado'), findsOneWidget);
      await tester.tap(find.text('Voltar para os documentos'));
      expect(wentBack, isTrue);
    });

    testWidgets('tapping a pending document opens it, with its van', (
      tester,
    ) async {
      final opened = <(DocumentType, String?)>[];
      await pumpStatus(
        tester,
        cubit.state.copyWith(step: SubmissionStep.sent),
        compliance: TestCompliance(
          driverRequirements: [
            rejected(DocumentType.criminalRecord),
            missing(DocumentType.municipalAuthorization, optional: true),
          ],
          vehicles: [
            TestVehicle(
              token: 'sprinter',
              plate: 'SDF4E21',
              model: 'Sprinter',
              requirements: [missing(DocumentType.vehicleInspection)],
            ),
          ],
        ),
        onOpenPending: (entry, vehicleToken) =>
            opened.add((entry.requirement.type, vehicleToken)),
      );

      expect(find.text('Alvará municipal'), findsNothing);
      await tester.tap(find.text('Certidão criminal'));
      await tester.tap(find.text('Vistoria semestral'));
      expect(opened, [
        (DocumentType.criminalRecord, null),
        (DocumentType.vehicleInspection, 'sprinter'),
      ]);
    });

    testWidgets('nothing missing hides the list', (tester) async {
      await pumpStatus(tester, cubit.state.copyWith(step: SubmissionStep.sent));

      expect(find.text('Pendências'), findsNothing);
    });

    testWidgets('a failed upload offers to try again or change the file', (
      tester,
    ) async {
      await pumpStatus(
        tester,
        cubit.state.copyWith(
          step: SubmissionStep.failed,
          failure: const NetworkSubmissionFailure(),
        ),
      );

      expect(find.text('Não deu para enviar'), findsOneWidget);
      expect(
        find.text(
          'A conexão caiu no meio do envio. O arquivo continua aqui, é só tentar de novo.',
        ),
        findsOneWidget,
      );
      expect(find.text('Tentar de novo'), findsOneWidget);
      await tester.tap(find.text('Trocar arquivo'));
      await tester.pumpAndSettle();
      expect(find.text('Como você quer enviar?'), findsOneWidget);
    });

    testWidgets('a refused file type says why', (tester) async {
      await pumpStatus(
        tester,
        cubit.state.copyWith(
          step: SubmissionStep.failed,
          failure: const UnsupportedFileFailure(),
        ),
      );

      expect(
        find.text('Este tipo de arquivo não é aceito. Envie PDF, JPG ou PNG.'),
        findsOneWidget,
      );
    });
  });
}
