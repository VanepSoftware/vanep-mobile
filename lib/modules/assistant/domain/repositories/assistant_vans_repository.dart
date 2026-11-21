import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_former_link.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_vans_overview.dart';

abstract class AssistantVansRepository {
  Future<Result<AssistantFailure, AssistantVansOverview>> findVansOverview();

  Future<Result<AssistantFailure, List<AssistantFormerLink>>> findFormerLinks();
}
