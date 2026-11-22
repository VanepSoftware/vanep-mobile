import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/compliance_failure.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/cubit/driver_compliance_cubit.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/pages/personal_documents_page.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/pages/vehicle_documents_page.dart';

import '../driver_documents_fixture.dart';
import 'documents_pages_harness.dart';

final personalCompliance = TestCompliance(
  driverRequirements: [
    approved(DocumentType.driverLicense, expiresAt: DateTime(2031, 8, 12)),
    underReview(DocumentType.schoolDriverCourse),
    rejected(DocumentType.criminalRecord),
    missing(DocumentType.municipalAuthorization, optional: true),
  ],
);

TestVehicle sprinter() => TestVehicle(
  token: 'sprinter',
  plate: 'SDF4E21',
  model: 'Sprinter',
  requirements: [
    approved(DocumentType.vehicleRegistration, expiresAt: DateTime(2027, 6, 1)),
    approved(DocumentType.vehicleInspection, expiresAt: DateTime(2026, 11, 29)),
    missing(DocumentType.schoolVehicleAuthorization),
  ],
);

TestVehicle master() => TestVehicle(
  token: 'master',
  plate: 'RTA3B45',
  model: 'Master',
  requirements: [
    approved(DocumentType.vehicleRegistration, expiresAt: DateTime(2027, 6, 1)),
    approved(DocumentType.vehicleInspection, expiresAt: DateTime(2027, 4, 1)),
    approved(
      DocumentType.schoolVehicleAuthorization,
      expiresAt: DateTime(2027, 9, 1),
    ),
  ],
);

void main() {
  group('personal documents (M1)', () {
    Future<void> pump(WidgetTester tester, DriverComplianceState state) {
      return tester.pumpWidget(
        documentsHarness(
          complianceCubitWith(state),
          PersonalDocumentsPage(onOpenDocument: (_) {}),
        ),
      );
    }

    testWidgets('pending first, then the sent ones, then the optional ones', (
      tester,
    ) async {
      await pump(tester, DriverComplianceState.ready(personalCompliance));

      expect(find.text('Documentos pessoais'), findsOneWidget);
      expect(find.text('Pendentes'), findsOneWidget);
      expect(find.text('Enviados'), findsOneWidget);
      expect(find.text('Certidão criminal'), findsOneWidget);
      expect(find.text('Reprovado'), findsOneWidget);
      expect(find.text('Não enviado · Opcional'), findsOneWidget);
      expect(find.text('Em análise'), findsOneWidget);
      expect(find.text('Aprovado'), findsOneWidget);
      expect(
        find.text(
          'Seus documentos só são vistos pela equipe Vanep que faz a análise.',
        ),
        findsOneWidget,
      );
      expect(find.text('Opcionais'), findsOneWidget);
      final pendingTop = tester.getTopLeft(find.text('Certidão criminal')).dy;
      final sentTop = tester.getTopLeft(find.text('CNH')).dy;
      final optionalTop = tester.getTopLeft(find.text('Alvará municipal')).dy;
      expect(pendingTop, lessThan(sentTop));
      expect(sentTop, lessThan(optionalTop));
      expect(
        tester.getTopLeft(find.text('Opcionais')).dy,
        greaterThan(sentTop),
      );
    });

    testWidgets('a group with nothing in it is hidden', (tester) async {
      await pump(
        tester,
        DriverComplianceState.ready(
          TestCompliance(
            driverRequirements: [approved(DocumentType.driverLicense)],
          ),
        ),
      );

      expect(find.text('Pendentes'), findsNothing);
      expect(find.text('Enviados'), findsOneWidget);
    });

    testWidgets('tapping a card opens that document', (tester) async {
      DocumentType? opened;
      await tester.pumpWidget(
        documentsHarness(
          complianceCubitWith(DriverComplianceState.ready(personalCompliance)),
          PersonalDocumentsPage(
            onOpenDocument: (entry) => opened = entry.requirement.type,
          ),
        ),
      );

      await tester.tap(find.text('Certidão criminal'));

      expect(opened, DocumentType.criminalRecord);
    });

    testWidgets('a failure shows the error with a retry', (tester) async {
      final cubit = complianceCubitWith(
        const DriverComplianceState.failed(ComplianceFailure.network),
      );
      await tester.pumpWidget(
        documentsHarness(cubit, PersonalDocumentsPage(onOpenDocument: (_) {})),
      );

      expect(find.byType(VanepErrorView), findsOneWidget);
      await tester.tap(find.text('Tentar novamente'));
      verify(cubit.load).called(1);
    });
  });

  group('van documents (M2)', () {
    Future<void> pump(
      WidgetTester tester,
      DriverComplianceState state, {
      String? onlyVehicleToken,
      VoidCallback? onRegisterVan,
    }) {
      return tester.pumpWidget(
        documentsHarness(
          complianceCubitWith(state),
          VehicleDocumentsPage(
            onlyVehicleToken: onlyVehicleToken,
            onOpenDocument: (_, _) {},
            onRegisterVan: onRegisterVan ?? () {},
          ),
        ),
      );
    }

    testWidgets('one section per van, the van with pending first', (
      tester,
    ) async {
      await pump(
        tester,
        DriverComplianceState.ready(
          TestCompliance(vehicles: [master(), sprinter()]),
        ),
      );

      expect(find.text('Documentos das vans'), findsOneWidget);
      expect(find.text('Sprinter · SDF4E21'), findsOneWidget);
      expect(find.text('2 pendentes'), findsOneWidget);
      expect(find.text('Master · RTA3B45'), findsOneWidget);
      expect(find.text('Em dia'), findsOneWidget);
      expect(find.text('Vence em 9 dias'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Sprinter · SDF4E21')).dy,
        lessThan(tester.getTopLeft(find.text('Master · RTA3B45')).dy),
      );
    });

    testWidgets('opened from the van central it shows only that van', (
      tester,
    ) async {
      await pump(
        tester,
        DriverComplianceState.ready(
          TestCompliance(vehicles: [master(), sprinter()]),
        ),
        onlyVehicleToken: 'master',
      );

      expect(find.text('Documentos da van'), findsOneWidget);
      expect(find.text('Master · RTA3B45'), findsOneWidget);
      expect(find.text('Sprinter · SDF4E21'), findsNothing);
    });

    testWidgets('without a van it asks to register one', (tester) async {
      var registered = false;
      await pump(
        tester,
        DriverComplianceState.ready(TestCompliance()),
        onRegisterVan: () => registered = true,
      );

      expect(
        find.text('Cadastre sua van para enviar os documentos dela'),
        findsOneWidget,
      );
      await tester.tap(find.text('Cadastrar van'));
      expect(registered, isTrue);
    });
  });
}
