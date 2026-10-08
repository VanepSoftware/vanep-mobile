import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/media/photo_failure.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/profile/domain/usecases/change_profile_photo.dart';

import '../../../../core/media/media_mocks.dart';
import '../../profile_fixtures.dart';
import '../../profile_mocks.dart';

void main() {
  test('uploads the photo for the signed-in profile', () async {
    final repository = MockProfileSummaryRepository();
    when(
      () => repository.uploadPhoto(testClientSummaryDto, testPickedPhoto),
    ).thenAnswer((_) async => const Ok<PhotoFailure, void>(null));

    final result = await ChangeProfilePhoto(repository)(
      testClientSummaryDto,
      testPickedPhoto,
    );

    expect(result.isOk, isTrue);
  });
}
