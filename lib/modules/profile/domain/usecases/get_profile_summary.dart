import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';
import 'package:vanep_mobile/modules/profile/domain/entities/profile_summary.dart';
import 'package:vanep_mobile/modules/profile/domain/failures/profile_summary_failure.dart';
import 'package:vanep_mobile/modules/profile/domain/repositories/profile_summary_repository.dart';

class GetProfileSummary {
  const GetProfileSummary(this.repository);

  final ProfileSummaryRepository repository;

  Future<Result<ProfileSummaryFailure, ProfileSummary>> call(UserType type) {
    return repository.fetchSummary(type);
  }
}
