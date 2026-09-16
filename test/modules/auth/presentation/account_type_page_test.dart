import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';
import 'package:vanep_mobile/modules/auth/presentation/pages/account_type_page.dart';

import 'auth_test_harness.dart';

void main() {
  testWidgets('offers the three self sign-up types', (tester) async {
    final chosen = <UserType>[];

    await tester.pumpWidget(
      authTestApp(
        AccountTypePage(
          onTypeSelected: (context, type) async => chosen.add(type),
        ),
      ),
    );

    expect(find.text('Como você quer usar a Vanep?'), findsOneWidget);
    await tester.tap(find.text('Sou cliente (responsável)'));
    await tester.tap(find.text('Sou motorista'));
    await tester.tap(find.text('Sou assistente'));

    expect(chosen, [UserType.client, UserType.driver, UserType.assistant]);
  });
}
