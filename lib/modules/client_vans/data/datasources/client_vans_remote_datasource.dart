import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/modules/client_vans/data/datasources/client_vans_datasource.dart';
import 'package:vanep_mobile/modules/client_vans/domain/entities/client_van.dart';

class ClientVansRemoteDataSource implements ClientVansDataSource {
  const ClientVansRemoteDataSource({
    required this.dio,
    required this.environment,
  });

  final Dio dio;
  final Environment environment;

  @override
  Future<List<ClientVan>> fetchMyVans() async {
    final response = await dio.get<List<dynamic>>(
      environment.clientDriversMeEndpoint,
    );
    final links = response.data ?? const [];

    if (links.isEmpty) {
      return const [];
    }

    final vans = <ClientVan>[];

    for (final rawLink in links) {
      final link = rawLink as Map<String, dynamic>;
      final linkToken = link['token'] as String? ?? '';
      final driverToken = link['driverToken'] as String? ?? '';
      final driverName = link['driverName'] as String? ?? '';
      final linkStatus = link['status'] as String? ?? 'ACTIVE';

      // 1. Fetch driver profile for vehicle & contact info
      String? driverPhone;
      String? driverPhoto;
      double? driverRating;
      ClientVanVehicle? vehicle;

      try {
        final profileRes = await dio.get<Map<String, dynamic>>(
          environment.driverProfileEndpoint(driverToken),
        );
        final profileData = profileRes.data ?? const {};
        driverPhone = profileData['phone'] as String?;
        driverPhoto = profileData['photo'] as String?;
        if (profileData['rating'] != null) {
          driverRating = (profileData['rating'] as num).toDouble();
        }

        final rawVehicles = profileData['vehicles'] as List<dynamic>? ?? const [];
        if (rawVehicles.isNotEmpty) {
          final v = rawVehicles.first as Map<String, dynamic>;
          vehicle = ClientVanVehicle(
            token: v['token'] as String? ?? '',
            brand: v['brand'] as String? ?? 'Van',
            model: v['model'] as String? ?? 'Escolar',
            manufactureYear: v['manufactureYear'] as int? ?? DateTime.now().year,
            color: v['color'] as String? ?? 'Branca',
            capacity: v['capacity'] as int? ?? 15,
            photoFrontUrl: v['photoFront'] as String?,
            photoSideUrl: v['photoSide'] as String?,
          );
        }
      } catch (_) {
        // Fallback or ignore profile fetch failure
      }

      vehicle ??= ClientVanVehicle(
        token: 'veh-$driverToken',
        brand: 'Van',
        model: 'Escolar',
        manufactureYear: DateTime.now().year,
        color: 'Branca',
        capacity: 15,
      );

      final driver = ClientVanDriver(
        token: driverToken,
        name: driverName.isNotEmpty ? driverName : 'Motorista',
        phone: driverPhone,
        photoUrl: driverPhoto,
        rating: driverRating,
      );

      // 2. Fetch contracts
      ClientVanContract? contract;
      final dependents = <ClientVanDependent>[];

      try {
        final contractsRes = await dio.get<List<dynamic>>(
          environment.clientDriverContractsEndpoint(linkToken),
        );
        final rawContracts = contractsRes.data ?? const [];
        if (rawContracts.isNotEmpty) {
          final c = rawContracts.first as Map<String, dynamic>;
          final startsOn = c['startsOn'] != null
              ? DateTime.tryParse(c['startsOn'] as String) ?? DateTime.now()
              : DateTime.now();
          final endsOn = c['endsOn'] != null
              ? DateTime.tryParse(c['endsOn'] as String) ?? DateTime.now()
              : DateTime.now();
          final totalAmount = (c['totalAmount'] as num?)?.toDouble() ?? 0.0;
          final installments = (c['installments'] as num?)?.toInt() ?? 12;
          final installmentAmount =
              (c['installmentAmount'] as num?)?.toDouble() ??
                  (totalAmount / (installments > 0 ? installments : 1));
          final dueDay = (c['dueDay'] as num?)?.toInt() ?? 5;

          contract = ClientVanContract(
            token: c['token'] as String? ?? '',
            status: c['status'] as String? ?? 'ACTIVE',
            startsOn: startsOn,
            endsOn: endsOn,
            totalAmount: totalAmount,
            installments: installments,
            installmentAmount: installmentAmount,
            dueDay: dueDay,
          );

          final rawItems = c['items'] as List<dynamic>? ?? const [];
          for (final rawItem in rawItems) {
            final item = rawItem as Map<String, dynamic>;
            final dependentToken = item['dependentToken'] as String? ?? '';
            final dependentName = item['dependentName'] as String? ?? '';
            final schoolName = item['schoolName'] as String? ?? '';
            final street = item['pickupStreet'] as String? ?? '';
            final number = item['pickupNumber'] as String? ?? '';
            final neighborhood = item['pickupNeighborhood'] as String? ?? '';
            final address = [street, number, neighborhood]
                .where((s) => s.isNotEmpty)
                .join(', ');

            String? pickupTime;
            String? returnTime;
            String shift = 'Manhã';

            final rawSlots = item['slots'] as List<dynamic>? ?? const [];
            for (final rawSlot in rawSlots) {
              final slot = rawSlot as Map<String, dynamic>;
              final leg = slot['leg'] as String? ?? '';
              final time = slot['pickupTime'] as String?;
              if (slot['shift'] != null) {
                shift = slot['shift'] as String;
              }
              if (leg == 'OUTBOUND' && time != null) {
                pickupTime = time;
              } else if (leg == 'RETURN' && time != null) {
                returnTime = time;
              }
            }

            dependents.add(
              ClientVanDependent(
                token: dependentToken,
                name: dependentName,
                schoolName: schoolName,
                pickupAddress: address,
                shift: shift,
                pickupTime: pickupTime,
                returnTime: returnTime,
              ),
            );
          }
        }
      } catch (_) {
        // Fallback or ignore contract fetch failure
      }

      vans.add(
        ClientVan(
          token: linkToken,
          status: linkStatus,
          driver: driver,
          vehicle: vehicle,
          contract: contract,
          dependents: dependents,
        ),
      );
    }

    return vans;
  }
}
