import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/get_active_trip_route.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/record_no_show.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/update_checklist_status.dart';

class MockGetActiveTripRoute extends Mock implements GetActiveTripRoute {}

class MockUpdateChecklistStatus extends Mock implements UpdateChecklistStatus {}

class MockRecordNoShow extends Mock implements RecordNoShow {}
