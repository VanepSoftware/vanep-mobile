import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/media/image_picker_photo_picker.dart';
import 'package:vanep_mobile/core/media/photo_failure.dart';
import 'package:vanep_mobile/core/media/photo_source.dart';
import 'package:vanep_mobile/core/media/picked_photo.dart';

class MockImagePicker extends Mock implements ImagePicker {}

void main() {
  late MockImagePicker imagePicker;
  late ImagePickerPhotoPicker picker;

  setUpAll(() => registerFallbackValue(ImageSource.gallery));

  setUp(() {
    imagePicker = MockImagePicker();
    picker = ImagePickerPhotoPicker(picker: imagePicker);
  });

  void stubPick(Future<XFile?> Function() answer) {
    when(
      () => imagePicker.pickImage(
        source: any(named: 'source'),
        maxWidth: any(named: 'maxWidth'),
        maxHeight: any(named: 'maxHeight'),
        imageQuality: any(named: 'imageQuality'),
      ),
    ).thenAnswer((_) => answer());
  }

  test('returns the chosen photo, shrunk before upload', () async {
    stubPick(() async => XFile('/tmp/van.jpg', name: 'van.jpg'));

    final result = await picker.pick(PhotoSource.camera);

    expect(
      result.valueOrNull,
      const PickedPhoto(path: '/tmp/van.jpg', fileName: 'van.jpg'),
    );
    verify(
      () => imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxPickedPhotoDimension,
        maxHeight: maxPickedPhotoDimension,
        imageQuality: pickedPhotoQuality,
      ),
    ).called(1);
  });

  test('returns no photo when the user cancels', () async {
    stubPick(() async => null);

    final result = await picker.pick(PhotoSource.gallery);

    expect(result.isOk, isTrue);
    expect(result.valueOrNull, isNull);
  });

  test('reports a denied permission apart from other errors', () async {
    stubPick(() async => throw PlatformException(code: 'photo_access_denied'));
    expect(
      (await picker.pick(PhotoSource.gallery)).errorOrNull,
      PhotoFailure.permissionDenied,
    );

    stubPick(() async => throw PlatformException(code: 'no_available_camera'));
    expect(
      (await picker.pick(PhotoSource.camera)).errorOrNull,
      PhotoFailure.unexpected,
    );
  });
}
