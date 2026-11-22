import 'package:vanep_mobile/modules/client_vans/domain/entities/client_van.dart';

final testClientVan = ClientVan(
  token: 'link-van-test-01',
  status: 'ACTIVE',
  driver: const ClientVanDriver(
    token: 'driver-test-01',
    name: 'Carlos Alberto Silva',
    phone: '(11) 98765-4321',
    rating: 4.9,
  ),
  vehicle: const ClientVanVehicle(
    token: 'veh-test-01',
    brand: 'Mercedes-Benz',
    model: 'Sprinter 415 CDI',
    manufactureYear: 2022,
    color: 'Branca',
    capacity: 15,
    plate: 'ABC-4E21',
  ),
  contract: ClientVanContract(
    token: 'contract-test-01',
    status: 'ACTIVE',
    startsOn: DateTime(2026, 2, 1),
    endsOn: DateTime(2026, 12, 20),
    totalAmount: 4200.00,
    installments: 12,
    installmentAmount: 350.00,
    dueDay: 5,
  ),
  dependents: const [
    ClientVanDependent(
      token: 'dep-test-01',
      name: 'Lucas Silva',
      schoolName: 'Colégio Santo Agostinho',
      pickupAddress: 'Rua das Flores, 123 - Jardins',
      shift: 'Manhã',
      pickupTime: '06:40',
      returnTime: '12:10',
      weekdays: ['Seg', 'Ter', 'Qua', 'Qui', 'Sex'],
    ),
  ],
);
