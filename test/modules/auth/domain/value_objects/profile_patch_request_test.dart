import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/gender.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/profile_patch_request.dart';

void main() {
  test('toJsonMap includes only fields marked by the builder', () {
    final request = (ProfilePatchRequestBuilder()
          ..setName('Maria Silva')
          ..setGender(Gender.female))
        .build();

    expect(request.toJsonMap(), {
      'name': 'Maria Silva',
      'gender': 'FEMALE',
    });
    expect(request.includesPhone, isFalse);
  });

  test('empty builder yields empty map', () {
    expect(ProfilePatchRequestBuilder().build().toJsonMap(), isEmpty);
    expect(ProfilePatchRequestBuilder().build().isEmpty, isTrue);
  });

  test('setPhone marks phone without sending other keys', () {
    final request = (ProfilePatchRequestBuilder()..setPhone('11988887777'))
        .build();

    expect(request.toJsonMap(), {'phone': '11988887777'});
  });
}
