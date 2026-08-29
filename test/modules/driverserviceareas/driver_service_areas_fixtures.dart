import 'package:vanep_mobile/modules/driverserviceareas/domain/entities/service_area.dart';
import 'package:vanep_mobile/modules/driverserviceareas/domain/entities/service_area_draft.dart';

const testQnl5Area = ServiceArea(
  token: 'area-qnl5',
  name: 'QNL 5',
  cityName: 'Brasília',
  stateUf: 'DF',
  coversWholeCity: false,
);

const testAguasClarasArea = ServiceArea(
  token: 'area-aguas',
  name: 'Águas Claras',
  cityName: 'Brasília',
  stateUf: 'DF',
  coversWholeCity: false,
);

const testQnl5Draft = ServiceAreaDraft(
  placeId: 'place-qnl5',
  label: 'QNL 5',
  sessionToken: 'session-1',
);

const testAguasClarasDraft = ServiceAreaDraft(
  placeId: 'place-aguas',
  label: 'Águas Claras',
  sessionToken: 'session-2',
);

List<ServiceAreaDraft> draftsOfSize(int size) {
  return List.generate(
    size,
    (index) => ServiceAreaDraft(placeId: 'place-$index', label: 'Área $index'),
  );
}
