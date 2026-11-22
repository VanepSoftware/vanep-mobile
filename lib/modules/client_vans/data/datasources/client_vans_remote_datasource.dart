import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/modules/client_vans/data/datasources/client_vans_datasource.dart';
import 'package:vanep_mobile/modules/client_vans/domain/entities/client_van.dart';

const _openRequestStatuses = ['OPEN', 'ANSWERED', 'ADJUSTMENT_REQUESTED'];

const _inProgressContractStatuses = {
  'AWAITING_SIGNATURES',
  'SIGNED',
  'ACTIVE',
  'SUSPENDED',
};

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

    final needsOpenRequestCheck = links.any((raw) {
      final link = raw as Map<String, dynamic>;
      final status = (link['status'] as String? ?? 'ACTIVE').toUpperCase();
      return status == 'PENDING';
    });
    final openNegotiationKeys = needsOpenRequestCheck
        ? await _fetchOpenNegotiationKeys()
        : null;

    final vans = <ClientVan>[];

    for (final rawLink in links) {
      final link = rawLink as Map<String, dynamic>;
      final linkToken = link['token'] as String? ?? '';
      final driverToken = link['driverToken'] as String? ?? '';
      final driverName = link['driverName'] as String? ?? '';
      final linkStatus = link['status'] as String? ?? 'ACTIVE';
      final normalizedLinkStatus = linkStatus.toUpperCase();

      // 1. Fetch contracts first to know whether this link has an active/pending contract
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

      if (!_shouldDisplayLink(
        normalizedLinkStatus: normalizedLinkStatus,
        linkToken: linkToken,
        driverToken: driverToken,
        contract: contract,
        openNegotiationKeys: openNegotiationKeys,
      )) {
        continue;
      }

      // 2. Fetch driver profile for vehicle & contact info
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

  Future<Set<String>?> _fetchOpenNegotiationKeys() async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        environment.clientServiceRequestsEndpoint,
        queryParameters: {
          'status': _openRequestStatuses,
          'size': 50,
        },
      );
      final content = response.data?['content'];
      if (content is! List) return const {};
      final keys = <String>{};
      for (final item in content.whereType<Map<String, dynamic>>()) {
        final linkToken = item['clientDriverToken'] as String?;
        final driverToken = item['driverToken'] as String?;
        if (linkToken != null && linkToken.isNotEmpty) keys.add(linkToken);
        if (driverToken != null && driverToken.isNotEmpty) {
          keys.add(driverToken);
        }
      }
      return keys;
    } catch (_) {
      return null;
    }
  }

  bool _shouldDisplayLink({
    required String normalizedLinkStatus,
    required String linkToken,
    required String driverToken,
    required ClientVanContract? contract,
    required Set<String>? openNegotiationKeys,
  }) {
    if (normalizedLinkStatus == 'ACTIVE' || normalizedLinkStatus == 'ATIVA') {
      return true;
    }
    if (contract != null &&
        _inProgressContractStatuses.contains(contract.status.toUpperCase())) {
      return true;
    }
    if (normalizedLinkStatus != 'PENDING' &&
        normalizedLinkStatus != 'PENDENTE') {
      return false;
    }
    if (contract != null) {
      // Has only a closed/cancelled contract and no active status.
      return false;
    }
    if (openNegotiationKeys == null) return true;
    return openNegotiationKeys.contains(linkToken) ||
        openNegotiationKeys.contains(driverToken);
  }
}
