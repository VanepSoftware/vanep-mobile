import 'package:vanep_mobile/modules/client_vans/data/datasources/client_vans_datasource.dart';
import 'package:vanep_mobile/modules/client_vans/domain/entities/client_van.dart';

// TODO(VAN-101): mocked client vans datasource to provide full sample data
// for preview and testing when client has no active contracts in local dev.
class MockedClientVansDataSource implements ClientVansDataSource {
  const MockedClientVansDataSource();

  @override
  Future<List<ClientVan>> fetchMyVans() async {
    return [
      ClientVan(
        token: 'link-van-01',
        status: 'ACTIVE',
        driver: const ClientVanDriver(
          token: 'driver-carlos-01',
          name: 'Carlos Alberto Silva',
          phone: '(11) 98765-4321',
          rating: 4.9,
        ),
        vehicle: const ClientVanVehicle(
          token: 'veh-sprinter-01',
          brand: 'Mercedes-Benz',
          model: 'Sprinter 415 CDI',
          manufactureYear: 2022,
          color: 'Branca',
          capacity: 15,
          plate: 'ABC-4E21',
        ),
        contract: ClientVanContract(
          token: 'contract-001',
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
            token: 'dep-lucas-01',
            name: 'Lucas Silva',
            schoolName: 'Colégio Santo Agostinho',
            pickupAddress: 'Rua das Flores, 123 - Jardins',
            shift: 'Manhã',
            pickupTime: '06:40',
            returnTime: '12:10',
            weekdays: ['Seg', 'Ter', 'Qua', 'Qui', 'Sex'],
          ),
          ClientVanDependent(
            token: 'dep-mariana-02',
            name: 'Mariana Silva',
            schoolName: 'Colégio Santo Agostinho',
            pickupAddress: 'Rua das Flores, 123 - Jardins',
            shift: 'Manhã',
            pickupTime: '06:40',
            returnTime: '12:10',
            weekdays: ['Seg', 'Ter', 'Qua', 'Qui', 'Sex'],
          ),
        ],
      ),
      ClientVan(
        token: 'link-van-02',
        status: 'PENDING',
        driver: const ClientVanDriver(
          token: 'driver-juliana-02',
          name: 'Juliana Mendes',
          phone: '(11) 99123-4567',
          rating: 4.8,
        ),
        vehicle: const ClientVanVehicle(
          token: 'veh-master-02',
          brand: 'Renault',
          model: 'Master Escolar',
          manufactureYear: 2023,
          color: 'Prata',
          capacity: 15,
          plate: 'DEF-9B12',
        ),
        contract: ClientVanContract(
          token: 'contract-002',
          status: 'PENDING',
          startsOn: DateTime(2026, 3, 1),
          endsOn: DateTime(2026, 12, 20),
          totalAmount: 3840.00,
          installments: 12,
          installmentAmount: 320.00,
          dueDay: 10,
        ),
        dependents: const [
          ClientVanDependent(
            token: 'dep-pedro-03',
            name: 'Pedro Costa',
            schoolName: 'Colégio Bandeirantes',
            pickupAddress: 'Av. Paulista, 500 - Bela Vista',
            shift: 'Tarde',
            pickupTime: '12:30',
            returnTime: '18:00',
            weekdays: ['Seg', 'Ter', 'Qua', 'Qui', 'Sex'],
          ),
        ],
      ),
    ];
  }
}
