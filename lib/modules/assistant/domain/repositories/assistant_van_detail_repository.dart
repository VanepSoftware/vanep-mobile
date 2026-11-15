import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_van_detail.dart';

abstract class AssistantVanDetailRepository {
  Future<Result<AssistantFailure, AssistantVanDetail>> findVanDetail(
    String vanToken,
  );

  Future<Result<AssistantFailure, void>> leaveVan(String vanToken);
}
