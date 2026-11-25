import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/media/picked_document.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/document_submission_failure.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/submit_document.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_upload.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/cubit/document_submission_cubit.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/cubit/driver_compliance_cubit.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/pages/document_confirm_page.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/pages/document_image_page.dart';

import '../../../core/media/document_capture_fixture.dart';
import '../../../core/media/media_mocks.dart';
import '../driver_documents_fixture.dart';
import '../driver_documents_mocks.dart';
import 'documents_pages_harness.dart';

const galleryPhoto = PickedDocument(
  path: '/tmp/vanep_documents/1-image_picker_C8F1A2B3D4E5.jpg',
  fileName: 'image_picker_C8F1A2B3D4E5.jpg',
  mimeType: 'image/jpeg',
  sizeBytes: 300000,
  pagePreviewPaths: ['/tmp/vanep_documents/1-image_picker_C8F1A2B3D4E5.jpg'],
);

const pickedPdf = PickedDocument(
  path: '/tmp/vanep_documents/1-crlv.pdf',
  fileName: 'crlv.pdf',
  mimeType: 'application/pdf',
  sizeBytes: 800 * 1024,
);

void main() {
  late MockDocumentSubmissionRepository submissions;

  setUpAll(
    () => registerFallbackValue(
      const DocumentUpload(
        type: DocumentType.criminalRecord,
        file: testScannedDocument,
      ),
    ),
  );

  setUp(() => submissions = MockDocumentSubmissionRepository());

  DocumentSubmissionCubit cubitFor(
    DocumentType type, {
    String? vehicleToken,
    PickedDocument file = testScannedDocument,
  }) {
    final cubit = DocumentSubmissionCubit(
      type: type,
      vehicleToken: vehicleToken,
      documentCapture: MockDocumentCapture(),
      submitDocument: SubmitDocument(submissions),
    );
    cubit.emit(
      cubit.state.copyWith(step: SubmissionStep.confirming, file: file),
    );
    addTearDown(cubit.close);
    return cubit;
  }

  Future<List<String>> pumpConfirm(
    WidgetTester tester,
    DocumentSubmissionCubit cubit, {
    String? vehicleCaption,
    bool pdfOpens = true,
  }) async {
    final openedPdfs = <String>[];
    await tester.pumpWidget(
      documentsHarness(
        complianceCubitWith(DriverComplianceState.ready(TestCompliance())),
        BlocProvider<DocumentSubmissionCubit>.value(
          value: cubit,
          child: DocumentConfirmPage(
            vehicleCaption: vehicleCaption,
            onOpenPdf: (path) async {
              openedPdfs.add(path);
              return pdfOpens;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return openedPdfs;
  }

  testWidgets('shows the pages of the scan and what to check', (tester) async {
    await pumpConfirm(tester, cubitFor(DocumentType.driverLicense));

    expect(find.text('CNH'), findsOneWidget);
    expect(find.text('1 de 2'), findsOneWidget);
    expect(find.text('PDF · 2 páginas · 1,4 MB'), findsOneWidget);
    expect(find.text('Trocar arquivo'), findsOneWidget);
    expect(find.text('Antes de enviar, confira'), findsOneWidget);
    expect(find.text('Dá para ler tudo'), findsOneWidget);
    expect(
      find.text('O documento aparece inteiro, sem cortes'),
      findsOneWidget,
    );
    expect(find.text('Frente e verso, quando tiver'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('swiping shows the next page', (tester) async {
    await pumpConfirm(tester, cubitFor(DocumentType.driverLicense));

    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(find.text('2 de 2'), findsOneWidget);
  });

  testWidgets('tapping a page opens it full screen', (tester) async {
    await pumpConfirm(tester, cubitFor(DocumentType.driverLicense));

    await tester.tap(find.bySemanticsLabel('Página 1'));
    await tester.pumpAndSettle();

    expect(find.byType(DocumentImagePage), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsOneWidget);
  });

  testWidgets('a gallery photo shows itself, without its name', (tester) async {
    await pumpConfirm(
      tester,
      cubitFor(DocumentType.criminalRecord, file: galleryPhoto),
    );

    expect(find.text('JPG · 0,3 MB'), findsOneWidget);
    expect(find.textContaining('image_picker'), findsNothing);
    expect(find.text('1 de 1'), findsNothing);
  });

  testWidgets('a PDF from the phone opens in the system viewer', (
    tester,
  ) async {
    final opened = await pumpConfirm(
      tester,
      cubitFor(DocumentType.criminalRecord, file: pickedPdf),
    );

    await tester.tap(find.text('Abrir PDF'));
    await tester.pumpAndSettle();

    expect(opened, ['/tmp/vanep_documents/1-crlv.pdf']);
  });

  testWidgets('a PDF that does not open says so', (tester) async {
    await pumpConfirm(
      tester,
      cubitFor(DocumentType.criminalRecord, file: pickedPdf),
      pdfOpens: false,
    );

    await tester.tap(find.text('Abrir PDF'));
    await tester.pumpAndSettle();

    expect(find.text('Não deu para abrir o arquivo.'), findsOneWidget);
  });

  testWidgets('a van document shows its van under the title', (tester) async {
    await pumpConfirm(
      tester,
      cubitFor(DocumentType.vehicleInspection, vehicleToken: 'sprinter'),
      vehicleCaption: 'Sprinter · SDF4E21',
    );

    expect(find.text('Vistoria semestral'), findsOneWidget);
    expect(find.text('Sprinter · SDF4E21'), findsOneWidget);
  });

  testWidgets('change file goes back to the choice of source', (tester) async {
    await pumpConfirm(tester, cubitFor(DocumentType.criminalRecord));

    await tester.tap(find.text('Trocar arquivo'));
    await tester.pumpAndSettle();

    expect(find.text('Como você quer enviar?'), findsOneWidget);
  });

  testWidgets('send for review sends the file with its type', (tester) async {
    when(() => submissions.send(any(), onProgress: any(named: 'onProgress')))
        .thenAnswer((_) async => const Ok('doc-1'));
    final cubit = cubitFor(DocumentType.criminalRecord);
    await pumpConfirm(tester, cubit);

    await tester.tap(find.text('Enviar para análise'));
    await tester.pumpAndSettle();

    expect(cubit.state.step, SubmissionStep.sent);
    verify(
      () => submissions.send(
        const DocumentUpload(
          type: DocumentType.criminalRecord,
          file: testScannedDocument,
        ),
        onProgress: any(named: 'onProgress'),
      ),
    ).called(1);
  });

  testWidgets('a file the back refuses says why above the button', (
    tester,
  ) async {
    final cubit = cubitFor(DocumentType.criminalRecord);
    cubit.emit(cubit.state.copyWith(failure: const UnsupportedFileFailure()));
    await pumpConfirm(tester, cubit);

    expect(
      find.text('Este tipo de arquivo não é aceito. Envie PDF, JPG ou PNG.'),
      findsOneWidget,
    );
  });
}
