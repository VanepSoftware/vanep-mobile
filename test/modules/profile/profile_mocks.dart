import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/profile/domain/repositories/profile_summary_repository.dart';
import 'package:vanep_mobile/modules/profile/domain/usecases/change_profile_photo.dart';
import 'package:vanep_mobile/modules/profile/domain/usecases/get_profile_summary.dart';
import 'package:vanep_mobile/modules/profile/presentation/cubit/profile_photo_cubit.dart';
import 'package:vanep_mobile/modules/profile/presentation/cubit/profile_photo_state.dart';
import 'package:vanep_mobile/modules/profile/presentation/cubit/profile_summary_cubit.dart';

class MockProfileSummaryRepository extends Mock
    implements ProfileSummaryRepository {}

class MockGetProfileSummary extends Mock implements GetProfileSummary {}

class MockProfileSummaryCubit extends MockCubit<ProfileSummaryState>
    implements ProfileSummaryCubit {}

class MockChangeProfilePhoto extends Mock implements ChangeProfilePhoto {}

class MockProfilePhotoCubit extends MockCubit<ProfilePhotoState>
    implements ProfilePhotoCubit {}
