import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_van_detail_repository.dart';

class LeaveAssistantVan {
  const LeaveAssistantVan(this.repository);

  final AssistantVanDetailRepository repository;

  Future<Result<AssistantFailure, void>> call(String vanToken) {
    return repository.leaveVan(vanToken);
  }
}
