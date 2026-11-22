import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_van_detail_repository.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_van_detail.dart';

class FindAssistantVanDetail {
  const FindAssistantVanDetail(this.repository);

  final AssistantVanDetailRepository repository;

  Future<Result<AssistantFailure, AssistantVanDetail>> call(String vanToken) {
    return repository.findVanDetail(vanToken);
  }
}
