import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/mocked_assistant_vans_datasource.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_repository.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_vans_repository.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/find_assistant_vans.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/get_linked_vans.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/register_assistant_with_invite.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/validate_assistant_invite.dart';

class MockAssistantRepository extends Mock implements AssistantRepository {}

class MockValidateAssistantInvite extends Mock
    implements ValidateAssistantInvite {}

class MockRegisterAssistantWithInvite extends Mock
    implements RegisterAssistantWithInvite {}

class MockGetLinkedVans extends Mock implements GetLinkedVans {}

class MockAssistantVansRepository extends Mock
    implements AssistantVansRepository {}

class MockAssistantVansDataSource extends Mock
    implements AssistantVansDataSource {}

class MockFindAssistantVans extends Mock implements FindAssistantVans {}
