Map<String, Object?> requestDayJson({
  String weekday = 'MONDAY',
  bool needsOutbound = true,
  bool needsReturn = true,
}) {
  return {
    'weekday': weekday,
    'schoolShift': 'AFTERNOON',
    'needsOutbound': needsOutbound,
    'needsReturn': needsReturn,
  };
}

Map<String, Object?> proposalSummaryJson({bool hasPendingAdjustment = false}) {
  return {
    'token': 'proposal-v2',
    'version': 2,
    'status': 'SENT',
    'totalAmount': 3600.00,
    'installments': 12,
    'installmentAmount': 300.00,
    'lastInstallmentAmount': 300.00,
    'validUntil': '2026-10-09T12:00:00Z',
    'startsOn': '2027-02-15',
    'hasPendingAdjustment': hasPendingAdjustment,
  };
}

Map<String, Object?> clientServiceRequestJson({
  String status = 'ANSWERED',
  Map<String, Object?>? currentProposal,
  Object? driverRating = 4.8,
}) {
  return {
    'token': 'request-1',
    'clientDriverToken': 'link-1',
    'conversationToken': 'conversation-1',
    'driverToken': 'driver-carlos',
    'driverName': 'Carlos Souza',
    'driverRating': driverRating,
    'status': status,
    'desiredStartDate': '2027-02-01',
    'notes': 'Theo sai às 12h.',
    'declineReason': null,
    'expiresAt': '2026-10-04T12:00:00Z',
    'currentProposal': currentProposal,
    'items': [
      {
        'dependentToken': 'dep-theo',
        'dependentName': 'Theo Souza',
        'dependentBirthDate': '2017-03-22',
        'schoolName': 'Colégio Delta',
        'pickupCityName': 'Brasília',
        'pickupStateUf': 'DF',
        'pickupNeighborhood': 'Taguatinga',
        'days': [
          requestDayJson(),
          requestDayJson(weekday: 'WEDNESDAY', needsReturn: false),
        ],
      },
    ],
    'createdAt': '2026-10-01T12:00:00Z',
    'updatedAt': '2026-10-02T09:30:00Z',
  };
}

Map<String, Object?> driverServiceRequestJson() {
  return {
    'token': 'request-1',
    'clientDriverToken': 'link-1',
    'conversationToken': 'conversation-1',
    'clientFirstName': 'Maria',
    'status': 'OPEN',
    'desiredStartDate': '2027-02-01',
    'notes': null,
    'declineReason': null,
    'expiresAt': '2026-10-04T12:00:00Z',
    'currentProposal': null,
    'items': [
      {
        'dependentToken': 'dep-theo',
        'dependentFirstName': 'Theo',
        'dependentAge': 9,
        'schoolName': 'Colégio Delta',
        'pickupCityName': 'Brasília',
        'pickupStateUf': 'DF',
        'pickupNeighborhood': 'Taguatinga',
        'days': [requestDayJson()],
      },
    ],
    'createdAt': '2026-10-01T12:00:00Z',
    'updatedAt': '2026-10-01T12:00:00Z',
  };
}

Map<String, Object?> proposalJson({
  String? dependentName = 'Theo Souza',
  String? vehicleToken = 'van-master',
  Object? enrollmentFee = 150.00,
}) {
  return {
    'token': 'proposal-v2',
    'serviceRequestToken': 'request-1',
    'clientDriverToken': 'link-1',
    'version': 2,
    'status': 'SENT',
    'validUntil': '2026-10-09T12:00:00Z',
    'startsOn': '2027-02-15',
    'endsOn': '2027-12-17',
    'totalAmount': 1000.00,
    'installments': 3,
    'installmentAmount': 333.33,
    'lastInstallmentAmount': 333.34,
    'dueDay': 10,
    'enrollmentFee': enrollmentFee,
    'adjustmentPolicy': 'IPCA_AT_RENEWAL',
    'cancellationPolicy': 'NOTICE_30_DAYS_WITH_FEE',
    'vehicle': {
      'token': vehicleToken,
      'plate': 'JKL1A23',
      'brand': 'Renault',
      'model': 'Master',
      'manufactureYear': 2019,
      'color': 'Branca',
      'capacity': 15,
    },
    'message': 'Posso buscar 10 min antes.',
    'declineReason': null,
    'acceptedAt': null,
    'items': [
      {
        'dependentToken': 'dep-theo',
        'dependentName': dependentName,
        'dependentFirstName': 'Theo',
        'slots': [
          {
            'weekday': 'MONDAY',
            'leg': 'OUTBOUND',
            'shift': 'AFTERNOON',
            'pickupTime': '12:05:00',
          },
          {
            'weekday': 'MONDAY',
            'leg': 'RETURN',
            'shift': 'AFTERNOON',
            'pickupTime': '18:00',
          },
        ],
      },
    ],
    'adjustments': [
      {
        'field': 'PRICE',
        'suggestedValue': 'R\$ 290',
        'note': null,
        'createdAt': '2026-10-02T15:00:00Z',
      },
    ],
    'createdAt': '2026-10-03T10:00:00Z',
    'updatedAt': '2026-10-03T10:00:00Z',
  };
}

Map<String, Object?> pageJson(
  List<Map<String, Object?>> content, {
  bool last = true,
  int? totalElements,
}) {
  return {
    'content': content,
    'last': last,
    'totalElements': totalElements ?? content.length,
    'number': 0,
    'size': 20,
  };
}

Map<String, Object?> withoutField(Map<String, Object?> json, String field) {
  return {...json}..remove(field);
}

Map<String, Object?> withoutItemField(Map<String, Object?> json, String field) {
  final items = json['items']! as List<Object?>;
  return {
    ...json,
    'items': [
      for (final item in items)
        withoutField(item! as Map<String, Object?>, field),
    ],
  };
}
