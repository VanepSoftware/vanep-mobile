import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_repository.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/get_linked_vans.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/register_assistant_with_invite.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/validate_assistant_invite.dart';

class MockAssistantRepository extends Mock implements AssistantRepository {}

class MockValidateAssistantInvite extends Mock
    implements ValidateAssistantInvite {}

class MockRegisterAssistantWithInvite extends Mock
    implements RegisterAssistantWithInvite {}

class MockGetLinkedVans extends Mock implements GetLinkedVans {}
