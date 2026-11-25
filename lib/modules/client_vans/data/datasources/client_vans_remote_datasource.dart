import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/modules/client_vans/data/datasources/client_vans_datasource.dart';
import 'package:vanep_mobile/modules/client_vans/domain/entities/client_van.dart';
import 'package:vanep_mobile/modules/negotiations/data/datasources/negotiation_payloads.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

const _contractStatusPriority = [
  'ACTIVE',
  'SIGNED',
  'AWAITING_SIGNATURES',
  'SUSPENDED',
];

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
      final status = (link['status'] as String? ?? '').toUpperCase();
      return status == 'PENDING' || status == 'PENDENTE';
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
      final linkStatus = link['status'] as String? ?? '';
      final normalizedLinkStatus = linkStatus.toUpperCase();

      // 1. Fetch contracts first to know whether this link has an active/pending contract
      ClientVanContract? contract;
      final dependents = <ClientVanDependent>[];

      final contractsRes = await dio.get<List<dynamic>>(
        environment.clientDriverContractsEndpoint(linkToken),
      );
      final rawContracts = (contractsRes.data ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList();
      final selectedContract = _selectPrimaryContract(rawContracts);
      if (selectedContract != null) {
        final contractToken = selectedContract['token'] as String? ?? '';
        final contractStatus = selectedContract['status'] as String? ?? '';
        final startsOnRaw = selectedContract['startsOn'];
        final endsOnRaw = selectedContract['endsOn'];
        final startsOn = startsOnRaw is String
            ? DateTime.tryParse(startsOnRaw)
            : null;
        final endsOn = endsOnRaw is String
            ? DateTime.tryParse(endsOnRaw)
            : null;
        final totalAmount =
            (selectedContract['totalAmount'] as num?)?.toDouble();
        final installments =
            (selectedContract['installments'] as num?)?.toInt();
        final rawInstallmentAmount =
            (selectedContract['installmentAmount'] as num?)?.toDouble();
        final installmentAmount = rawInstallmentAmount ??
            (totalAmount != null && installments != null && installments > 0
                ? totalAmount / installments
                : null);
        final dueDay = (selectedContract['dueDay'] as num?)?.toInt();

        contract = ClientVanContract(
          token: contractToken,
          status: contractStatus,
          startsOn: startsOn,
          endsOn: endsOn,
          totalAmount: totalAmount,
          installments: installments,
          installmentAmount: installmentAmount,
          dueDay: dueDay,
        );

        final rawItems = selectedContract['items'] as List<dynamic>? ?? const [];
        for (final rawItem in rawItems.whereType<Map<String, dynamic>>()) {
          final dependentToken = rawItem['dependentToken'] as String? ?? '';
          final dependentName = rawItem['dependentName'] as String? ?? '';
          final schoolName = rawItem['schoolName'] as String? ?? '';
          final street = rawItem['pickupStreet'] as String? ?? '';
          final number = rawItem['pickupNumber'] as String? ?? '';
          final neighborhood = rawItem['pickupNeighborhood'] as String? ?? '';
          final address = [
            street,
            number,
            neighborhood,
          ].where((s) => s.isNotEmpty).join(', ');

          String? pickupTime;
          String? returnTime;
          SchoolShift? shift;

          final rawSlots = rawItem['slots'] as List<dynamic>? ?? const [];
          for (final slot in rawSlots.whereType<Map<String, dynamic>>()) {
            final leg = slot['leg'] as String? ?? '';
            final time = slot['pickupTime'] as String?;
            shift ??= SchoolShift.fromApi(slot['shift']);
            if (leg == 'OUTBOUND' && time != null) {
              pickupTime = time;
            } else if ((leg == 'RETURN' || leg == 'HOMEBOUND') &&
                time != null) {
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
      final profileRes = await dio.get<Map<String, dynamic>>(
        environment.driverProfileEndpoint(driverToken),
      );
      final profileData = profileRes.data ?? const {};
      final driverPhone = profileData['phone'] as String?;
      final driverPhoto = profileData['photo'] as String?;
      final driverRating = (profileData['rating'] as num?)?.toDouble();

      final rawVehicles = (profileData['vehicles'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList();
      final vehicle = _parsePrimaryVehicle(rawVehicles);

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

  Map<String, dynamic>? _selectPrimaryContract(
    List<Map<String, dynamic>> contracts,
  ) {
    if (contracts.isEmpty) return null;
    for (final priorityStatus in _contractStatusPriority) {
      for (final contract in contracts) {
        final status = (contract['status'] as String? ?? '').toUpperCase();
        if (status == priorityStatus) return contract;
      }
    }
    return contracts.first;
  }

  ClientVanVehicle? _parsePrimaryVehicle(
    List<Map<String, dynamic>> rawVehicles,
  ) {
    if (rawVehicles.isEmpty) return null;
    final v = rawVehicles.first;
    final brand = (v['brand'] as String? ?? '').trim();
    final model = (v['model'] as String? ?? '').trim();
    if (brand.isEmpty && model.isEmpty) return null;
    return ClientVanVehicle(
      token: v['token'] as String? ?? '',
      brand: brand,
      model: model,
      manufactureYear: (v['manufactureYear'] as num?)?.toInt(),
      color: (v['color'] as String?)?.trim().isEmpty == true
          ? null
          : v['color'] as String?,
      capacity: (v['capacity'] as num?)?.toInt(),
      plate: v['plate'] as String?,
      photoFrontUrl: v['photoFront'] as String?,
      photoSideUrl: v['photoSide'] as String?,
    );
  }

  Future<Set<String>> _fetchOpenNegotiationKeys() async {
    final response = await dio.get<Map<String, dynamic>>(
      environment.clientServiceRequestsEndpoint,
      queryParameters: {
        ...listQuery(statuses: openServiceRequestStatuses, page: 0),
        'size': 50,
      },
    );
    final content = response.data?['content'];
    if (content is! List) return const {};
    final openNames = {
      for (final status in openServiceRequestStatuses) status.apiName,
    };
    final keys = <String>{};
    for (final item in content.whereType<Map<String, dynamic>>()) {
      final rawStatus = (item['status'] as String?)?.toUpperCase();
      if (rawStatus != null && !openNames.contains(rawStatus)) continue;
      final linkToken = item['clientDriverToken'] as String?;
      final driverToken = item['driverToken'] as String?;
      if (linkToken != null && linkToken.isNotEmpty) keys.add(linkToken);
      if (driverToken != null && driverToken.isNotEmpty) {
        keys.add(driverToken);
      }
    }
    return keys;
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
    if (openNegotiationKeys == null) return false;
    return openNegotiationKeys.contains(linkToken) ||
        openNegotiationKeys.contains(driverToken);
  }
}
