import '../../../../core/result/result.dart';
import '../../../auth/domain/value_objects/user_type.dart';
import '../entities/profile_summary.dart';
import '../failures/profile_summary_failure.dart';
import '../repositories/profile_summary_repository.dart';

class GetProfileSummary {
  const GetProfileSummary(this.repository);

  final ProfileSummaryRepository repository;

  Future<Result<ProfileSummaryFailure, ProfileSummary>> call(UserType type) {
    return repository.fetchSummary(type);
  }
}
