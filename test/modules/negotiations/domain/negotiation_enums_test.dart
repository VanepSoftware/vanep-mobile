import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/operation_shift.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_field.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_policy.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_cancellation_policy.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_status.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/route_leg.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

void expectApiMapping<T>({
  required Map<String, T> valuesByApiName,
  required T? Function(Object? raw) fromApi,
  required String? Function(T? value) toApi,
}) {
  for (final MapEntry(key: apiName, value: value) in valuesByApiName.entries) {
    expect(fromApi(apiName), value, reason: apiName);
    expect(fromApi(apiName.toLowerCase()), value, reason: apiName);
    expect(fromApi(' $apiName '), value, reason: apiName);
    expect(toApi(value), apiName, reason: apiName);
  }
  expect(fromApi(null), isNull);
  expect(fromApi(''), isNull);
  expect(fromApi('UNKNOWN'), isNull);
  expect(fromApi(42), isNull);
  expect(toApi(null), isNull);
}

void main() {
  test('ServiceRequestStatus maps every API value both ways', () {
    expectApiMapping(
      valuesByApiName: const {
        'OPEN': ServiceRequestStatus.open,
        'ANSWERED': ServiceRequestStatus.answered,
        'CONVERTED': ServiceRequestStatus.converted,
        'DECLINED': ServiceRequestStatus.declined,
        'EXPIRED': ServiceRequestStatus.expired,
        'WITHDRAWN': ServiceRequestStatus.withdrawn,
      },
      fromApi: ServiceRequestStatus.fromApi,
      toApi: ServiceRequestStatus.toApi,
    );
  });

  test('ProposalStatus maps every API value both ways', () {
    expectApiMapping(
      valuesByApiName: const {
        'SENT': ProposalStatus.sent,
        'ACCEPTED': ProposalStatus.accepted,
        'SUPERSEDED': ProposalStatus.superseded,
        'DECLINED': ProposalStatus.declined,
        'EXPIRED': ProposalStatus.expired,
        'WITHDRAWN': ProposalStatus.withdrawn,
      },
      fromApi: ProposalStatus.fromApi,
      toApi: ProposalStatus.toApi,
    );
  });

  test('ProposalAdjustmentPolicy maps every API value both ways', () {
    expectApiMapping(
      valuesByApiName: const {
        'NONE': ProposalAdjustmentPolicy.none,
        'IPCA_AT_RENEWAL': ProposalAdjustmentPolicy.ipcaAtRenewal,
      },
      fromApi: ProposalAdjustmentPolicy.fromApi,
      toApi: ProposalAdjustmentPolicy.toApi,
    );
  });

  test('ProposalCancellationPolicy maps every API value both ways', () {
    expectApiMapping(
      valuesByApiName: const {
        'NOTICE_30_DAYS': ProposalCancellationPolicy.notice30Days,
        'NOTICE_30_DAYS_WITH_FEE':
            ProposalCancellationPolicy.notice30DaysWithFee,
      },
      fromApi: ProposalCancellationPolicy.fromApi,
      toApi: ProposalCancellationPolicy.toApi,
    );
  });

  test('ProposalAdjustmentField maps every API value both ways', () {
    expectApiMapping(
      valuesByApiName: const {
        'PRICE': ProposalAdjustmentField.price,
        'INSTALLMENTS': ProposalAdjustmentField.installments,
        'SCHEDULE': ProposalAdjustmentField.schedule,
        'PERIOD': ProposalAdjustmentField.period,
        'OTHER': ProposalAdjustmentField.other,
      },
      fromApi: ProposalAdjustmentField.fromApi,
      toApi: ProposalAdjustmentField.toApi,
    );
  });

  test('RouteLeg maps every API value both ways', () {
    expectApiMapping(
      valuesByApiName: const {
        'OUTBOUND': RouteLeg.outbound,
        'RETURN': RouteLeg.homebound,
      },
      fromApi: RouteLeg.fromApi,
      toApi: RouteLeg.toApi,
    );
  });

  test('OperationShift maps every API value both ways', () {
    expectApiMapping(
      valuesByApiName: const {
        'MORNING': OperationShift.morning,
        'AFTERNOON': OperationShift.afternoon,
        'NIGHT': OperationShift.night,
      },
      fromApi: OperationShift.fromApi,
      toApi: OperationShift.toApi,
    );
  });

  test('the open and the closed statuses split every status', () {
    expect(openServiceRequestStatuses, {
      ServiceRequestStatus.open,
      ServiceRequestStatus.answered,
    });
    expect(closedServiceRequestStatuses, {
      ServiceRequestStatus.converted,
      ServiceRequestStatus.declined,
      ServiceRequestStatus.expired,
      ServiceRequestStatus.withdrawn,
    });
    expect({
      ...openServiceRequestStatuses,
      ...closedServiceRequestStatuses,
    }, ServiceRequestStatus.values.toSet());
  });
}
