import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/media/picked_document.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/document_submission_failure.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/find_submission_for_resume.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/submit_document.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/upload_document_file.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_draft.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_field.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/cubit/document_submission_cubit.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/cubit/driver_compliance_cubit.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/pages/document_data_form_page.dart';

import '../../../core/media/document_capture_fixture.dart';
import '../../../core/media/media_mocks.dart';
import '../driver_documents_fixture.dart';
import '../driver_documents_mocks.dart';
import 'documents_pages_harness.dart';

void main() {
  late MockDocumentSubmissionRepository submissions;

  setUpAll(() {
    registerFallbackValue(
      const PersonalDocumentDraft(type: DocumentType.criminalRecord),
    );
    registerFallbackValue(testScannedDocument);
    registerFallbackValue(DocumentKind.driverDocument);
  });

  setUp(() {
    submissions = MockDocumentSubmissionRepository();
    when(() => submissions.create(any()))
        .thenAnswer((_) async => const Ok('doc-1'));
    when(
      () => submissions.uploadFile(
        any(),
        any(),
        any(),
        onProgress: any(named: 'onProgress'),
      ),
    ).thenAnswer((_) async => const Ok(null));
  });

  DocumentSubmissionCubit cubitFor(DocumentType type, {String? vehicleToken}) {
    final cubit = DocumentSubmissionCubit(
      type: type,
      vehicleToken: vehicleToken,
      documentCapture: MockDocumentCapture(),
      submitDocument: SubmitDocument(submissions),
      uploadDocumentFile: UploadDocumentFile(submissions),
      findSubmissionForResume: FindSubmissionForResume(submissions),
    );
    cubit.emit(
      cubit.state.copyWith(
        step: SubmissionStep.fillingData,
        file: testScannedDocument,
      ),
    );
    addTearDown(cubit.close);
    return cubit;
  }

  Future<void> pumpForm(
    WidgetTester tester,
    DocumentSubmissionCubit cubit, {
    String? vehicleCaption,
  }) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1.5;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      documentsHarness(
        complianceCubitWith(DriverComplianceState.ready(TestCompliance())),
        BlocProvider<DocumentSubmissionCubit>.value(
          value: cubit,
          child: DocumentDataFormPage(vehicleCaption: vehicleCaption),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  VoidCallback? submitAction(WidgetTester tester) =>
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed;

  Finder fieldFor(String label) =>
      find.ancestor(of: find.text(label), matching: find.byType(Column)).first;

  Future<void> typeIn(WidgetTester tester, String label, String text) async {
    await tester.enterText(
      find.descendant(of: fieldFor(label), matching: find.byType(TextField)),
      text,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the scanned file and the optional fields of the record', (
    tester,
  ) async {
    await pumpForm(tester, cubitFor(DocumentType.criminalRecord));

    expect(find.text('Documento escaneado'), findsOneWidget);
    expect(find.text('PDF · 2 páginas · 1,4 MB'), findsOneWidget);
    expect(find.byIcon(Icons.sync), findsOneWidget);
    expect(find.text('Trocar'), findsNothing);
    expect(find.text('Dados do documento'), findsOneWidget);
    expect(
      find.text('Copie do jeito que está escrito no documento.'),
      findsOneWidget,
    );
    expect(find.text('Número (opcional)'), findsOneWidget);
    expect(find.text('Válida até (opcional)'), findsOneWidget);
    expect(submitAction(tester), isNotNull);
  });

  testWidgets('sends what was typed', (tester) async {
    final cubit = cubitFor(DocumentType.criminalRecord);
    await pumpForm(tester, cubit);

    await typeIn(tester, 'Número (opcional)', 'CERT-2026-1');
    await tester.tap(find.text('Enviar para análise'));
    await tester.pumpAndSettle();

    verify(
      () => submissions.create(
        const PersonalDocumentDraft(
          type: DocumentType.criminalRecord,
          documentNumber: 'CERT-2026-1',
        ),
      ),
    ).called(1);
  });

  testWidgets('the municipal license waits for its number', (tester) async {
    await pumpForm(tester, cubitFor(DocumentType.municipalAuthorization));

    expect(find.text('Número do alvará'), findsOneWidget);
    expect(submitAction(tester), isNull);
    await typeIn(tester, 'Número do alvará', 'ALV-9');
    expect(submitAction(tester), isNotNull);
  });

  testWidgets('a van document shows the van, locked, and checks the date', (
    tester,
  ) async {
    await pumpForm(
      tester,
      cubitFor(DocumentType.vehicleInspection, vehicleToken: 'sprinter'),
      vehicleCaption: 'Sprinter · SDF4E21',
    );

    expect(find.text('Van'), findsOneWidget);
    expect(find.text('Sprinter · SDF4E21'), findsOneWidget);
    await typeIn(tester, 'Válida até', '24/11/2062');

    expect(find.text('Confira a data: ela está longe demais.'), findsOneWidget);
    expect(submitAction(tester), isNull);
  });

  testWidgets('the CRLV starts empty and explains which date to use', (
    tester,
  ) async {
    await pumpForm(
      tester,
      cubitFor(DocumentType.vehicleRegistration, vehicleToken: 'sprinter'),
    );

    expect(find.text('Válido até'), findsOneWidget);
    expect(
      find.text(
        'Data limite do próximo licenciamento, conforme o calendário do Detran para o final da sua placa.',
      ),
      findsOneWidget,
    );
    expect(submitAction(tester), isNull);
  });

  testWidgets('a picked photo shows a friendly title, never its file name', (
    tester,
  ) async {
    final cubit = cubitFor(DocumentType.criminalRecord);
    cubit.emit(
      cubit.state.copyWith(
        file: const PickedDocument(
          path: '/tmp/vanep_documents/image_picker_C8F1A2B3D4E5.jpg',
          fileName: 'image_picker_C8F1A2B3D4E5.jpg',
          mimeType: 'image/jpeg',
          sizeBytes: 2100 * 1024,
        ),
      ),
    );
    await pumpForm(tester, cubit);

    expect(find.text('Arquivo selecionado'), findsOneWidget);
    expect(find.textContaining('image_picker'), findsNothing);
  });

  testWidgets('tapping anywhere on the file card offers the ways again', (
    tester,
  ) async {
    await pumpForm(tester, cubitFor(DocumentType.criminalRecord));

    await tester.tap(find.text('PDF · 2 páginas · 1,4 MB'));
    await tester.pumpAndSettle();

    expect(find.text('Como você quer enviar?'), findsOneWidget);
  });

  testWidgets('the CNH asks its own fields, with only the school categories', (
    tester,
  ) async {
    await pumpForm(tester, cubitFor(DocumentType.driverLicense));

    expect(find.text('Número de registro'), findsOneWidget);
    expect(find.text('Data de emissão'), findsOneWidget);
    expect(find.text('Validade'), findsOneWidget);
    expect(find.text('UF emissora (opcional)'), findsOneWidget);

    await typeIn(tester, 'Número de registro', '12345678');
    expect(find.text('Use de 9 a 11 números.'), findsOneWidget);

    for (final category in ['D', 'E', 'AD', 'AE']) {
      expect(find.text(category), findsOneWidget);
    }
    for (final category in ['A', 'B', 'C', 'AB', 'AC']) {
      expect(find.text(category), findsNothing);
    }
  });

  testWidgets('the issuing state is picked from the list of states', (
    tester,
  ) async {
    await pumpForm(tester, cubitFor(DocumentType.driverLicense));

    expect(find.text('Selecione a UF'), findsOneWidget);
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('BA').last);
    await tester.pumpAndSettle();

    expect(find.text('Selecione a UF'), findsNothing);
    expect(find.text('BA'), findsOneWidget);
  });

  testWidgets('the calendar of an empty issue date opens on today', (
    tester,
  ) async {
    await pumpForm(tester, cubitFor(DocumentType.driverLicense));

    await tester.tap(find.byTooltip('Data de emissão'));
    await tester.pumpAndSettle();

    final picker = tester.widget<DatePickerDialog>(
      find.byType(DatePickerDialog),
    );
    expect(picker.initialDate, picker.lastDate);
    expect(picker.initialDate, testAsOf);
  });

  testWidgets('a date refused by the back shows on its field until edited', (
    tester,
  ) async {
    final cubit = cubitFor(
      DocumentType.vehicleInspection,
      vehicleToken: 'sprinter',
    );
    await pumpForm(tester, cubit);
    await typeIn(tester, 'Válida até', '01/03/2027');

    cubit.emit(
      cubit.state.copyWith(
        failure: const FieldRejectedFailure(
          field: DocumentField.expiresAt,
          error: DocumentFieldError.tooFar,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Confira a data: ela está longe demais.'), findsOneWidget);
    expect(submitAction(tester), isNull);

    await typeIn(tester, 'Válida até', '01/02/2027');
    expect(find.text('Confira a data: ela está longe demais.'), findsNothing);
    expect(submitAction(tester), isNotNull);
  });

  testWidgets('a category refused by the back shows until another is chosen', (
    tester,
  ) async {
    final cubit = cubitFor(DocumentType.driverLicense);
    await pumpForm(tester, cubit);

    cubit.emit(
      cubit.state.copyWith(
        failure: const FieldRejectedFailure(
          field: DocumentField.cnhCategory,
          error: DocumentFieldError.invalidFormat,
        ),
      ),
    );
    await tester.pumpAndSettle();
    const message = 'A categoria da CNH deve ser D, E, AD ou AE.';
    expect(find.text(message), findsOneWidget);

    await tester.tap(find.text('AD'));
    await tester.pumpAndSettle();
    expect(find.text(message), findsNothing);
  });

  testWidgets('a CNH number of another account shows on the number', (
    tester,
  ) async {
    final cubit = cubitFor(DocumentType.driverLicense);
    await pumpForm(tester, cubit);

    cubit.emit(cubit.state.copyWith(failure: const CnhNumberTakenFailure()));
    await tester.pumpAndSettle();

    expect(
      find.text('Este número de CNH já está em outro cadastro.'),
      findsOneWidget,
    );
  });

  testWidgets('finishing an incomplete upload fills the saved data', (
    tester,
  ) async {
    final cubit = cubitFor(
      DocumentType.vehicleInspection,
      vehicleToken: 'sprinter',
    );
    cubit.emit(
      cubit.state.copyWith(
        draft: VehicleDocumentDraft(
          vehicleToken: 'sprinter',
          type: DocumentType.vehicleInspection,
          documentNumber: 'LAUDO-77',
          expiresAt: DateTime(2027, 5, 31),
        ),
      ),
    );
    await pumpForm(tester, cubit);

    expect(find.text('LAUDO-77'), findsOneWidget);
    expect(find.text('31/05/2027'), findsOneWidget);
  });

  testWidgets('a refusal without field shows above the button', (tester) async {
    final cubit = cubitFor(DocumentType.criminalRecord);
    await pumpForm(tester, cubit);

    cubit.emit(cubit.state.copyWith(failure: const UnsupportedFileFailure()));
    await tester.pumpAndSettle();

    expect(
      find.text('Este tipo de arquivo não é aceito. Envie PDF, JPG ou PNG.'),
      findsOneWidget,
    );
  });
}
