import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/media/photo_picker.dart';
import 'package:vanep_mobile/core/media/picked_photo.dart';
import 'package:vanep_mobile/core/network/api_image_loader.dart';

class MockPhotoPicker extends Mock implements PhotoPicker {}

class MockApiImageLoader extends Mock implements ApiImageLoader {}

const testPickedPhoto = PickedPhoto(
  path: '/tmp/vanep/photo.jpg',
  fileName: 'photo.jpg',
);
