import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/media/document_capture_failure.dart';
import 'package:vanep_mobile/core/media/document_source.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/submit_document.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/cubit/document_submission_cubit.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/cubit/driver_compliance_cubit.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/widgets/document_source_sheet.dart';

import '../../../core/media/document_capture_fixture.dart';
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

  group('how to send (M3)', () {
    Future<List<bool>> openSheet(WidgetTester tester) async {
      final results = <bool>[];
      await tester.pumpWidget(
        host(
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async =>
                    results.add(await showDocumentSourceSheet(context, cubit)),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return results;
    }

    testWidgets('shows the three ways and the tip, with no badge', (
      tester,
    ) async {
      await openSheet(tester);

      expect(find.text('Autorização escolar'), findsOneWidget);
      expect(find.text('Como você quer enviar?'), findsOneWidget);
      expect(find.text('Escanear com a câmera'), findsOneWidget);
      expect(
        find.text(
          'Fotografe o documento agora com a câmera. Se ele tiver verso, fotografe os dois lados.',
        ),
        findsOneWidget,
      );
      expect(find.text('Recomendado'), findsNothing);
      expect(find.text('Escolher da galeria'), findsOneWidget);
      expect(find.text('Escolher arquivo PDF'), findsOneWidget);
      expect(
        find.text(
          'Documento inteiro na foto, sem reflexo e com tudo legível. PDF, JPG ou PNG de até 10 MB.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('a file too large is told and the sheet stays open', (
      tester,
    ) async {
      when(() => capture.capture(DocumentSource.pdfFile))
          .thenAnswer((_) async => const Err(DocumentCaptureFailure.tooLarge));
      final results = await openSheet(tester);

      await tester.tap(find.text('Escolher arquivo PDF'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'O arquivo passou de 10 MB. Escaneie de novo com menos páginas ou escolha um arquivo menor.',
        ),
        findsOneWidget,
      );
      expect(find.text('Como você quer enviar?'), findsOneWidget);
      expect(results, isEmpty);
    });

    testWidgets('a captured file closes the sheet and goes on', (tester) async {
      when(() => capture.capture(DocumentSource.scanner))
          .thenAnswer((_) async => const Ok(testScannedDocument));
      final results = await openSheet(tester);

      await tester.tap(find.text('Escanear com a câmera'));
      await tester.pumpAndSettle();

      expect(find.text('Como você quer enviar?'), findsNothing);
      expect(results, [true]);
      expect(cubit.state.step, SubmissionStep.confirming);
    });
  });
}
