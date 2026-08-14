import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/user_profile.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/profile_edit_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/patch_user_profile.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/refresh_user_profile.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/request_email_change.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/profile_patch_request.dart';

import '../../auth_fixtures.dart';
import '../../auth_mocks.dart';

void main() {
  late MockAuthRepository repository;

  setUpAll(registerAuthFallbacks);

  setUp(() {
    repository = MockAuthRepository();
  });

  test('RefreshUserProfile delegates to repository', () async {
    const profile = FakeUserProfile();
    when(repository.refreshUserProfile).thenAnswer(
      (_) async => const Ok<ProfileEditFailure, UserProfile>(profile),
    );

    final result = await RefreshUserProfile(repository)();

    expect(result.valueOrNull, profile);
  });

  test('PatchUserProfile delegates to repository', () async {
    const profile = FakeUserProfile(name: 'Maria');
    final request = (ProfilePatchRequestBuilder()..setName('Maria')).build();
    when(() => repository.patchUserProfile(any())).thenAnswer(
      (_) async => const Ok<ProfileEditFailure, UserProfile>(profile),
    );

    final result = await PatchUserProfile(repository)(request);

    expect(result.valueOrNull?.name, 'Maria');
  });

  test('RequestEmailChange delegates to repository', () async {
    const profile = FakeUserProfile(pendingEmail: 'novo@vanep.com.br');
    when(() => repository.requestEmailChange(any())).thenAnswer(
      (_) async => const Ok<ProfileEditFailure, UserProfile>(profile),
    );

    final result = await RequestEmailChange(repository)('novo@vanep.com.br');

    expect(result.valueOrNull?.pendingEmail, 'novo@vanep.com.br');
  });
}
