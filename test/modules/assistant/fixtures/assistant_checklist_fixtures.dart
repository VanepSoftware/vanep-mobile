import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_checklist_item.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_trip_stop.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/boarding_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/confirmation_source.dart';

const tStudent1 = AssistantChecklistItem(
  studentToken: 'stu-1',
  studentName: 'Ana Clara',
  schoolName: 'Colégio São Bento',
  stopId: 'stop-1',
  stopAddress: 'Rua das Flores, 100',
  status: BoardingStatus.pending,
);

const tStudent2 = AssistantChecklistItem(
  studentToken: 'stu-2',
  studentName: 'Bruno Lima',
  schoolName: 'Colégio São Bento',
  stopId: 'stop-2',
  stopAddress: 'Av. Paulista, 500',
  status: BoardingStatus.boarded,
  confirmedBy: ConfirmationSource.driver,
);

const tStop1 = AssistantTripStop(
  id: 'stop-1',
  order: 1,
  title: 'Parada Residencial',
  address: 'Rua das Flores, 100',
  isSchool: false,
  items: [tStudent1],
);

const tStop2 = AssistantTripStop(
  id: 'stop-2',
  order: 2,
  title: 'Colégio São Bento',
  address: 'Av. Paulista, 500',
  isSchool: true,
  items: [tStudent1, tStudent2],
);
