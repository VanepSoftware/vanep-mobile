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
    ];
  }
}
