import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/profile/domain/value_objects/driver_approval_status.dart';

void main() {
  test('DriverApprovalStatus.fromApi maps known API values', () {
    expect(DriverApprovalStatus.fromApi('PENDING'), DriverApprovalStatus.pending);
    expect(
      DriverApprovalStatus.fromApi('APPROVED'),
      DriverApprovalStatus.approved,
    );
    expect(
      DriverApprovalStatus.fromApi('REJECTED'),
      DriverApprovalStatus.rejected,
    );
  });

  test('DriverApprovalStatus.fromApi returns null for unknown values', () {
    expect(DriverApprovalStatus.fromApi(null), isNull);
    expect(DriverApprovalStatus.fromApi(''), isNull);
    expect(DriverApprovalStatus.fromApi('OTHER'), isNull);
  });

  test('DriverApprovalStatus.toApi maps enum values', () {
    expect(DriverApprovalStatus.toApi(DriverApprovalStatus.pending), 'PENDING');
    expect(
      DriverApprovalStatus.toApi(DriverApprovalStatus.approved),
      'APPROVED',
    );
    expect(
      DriverApprovalStatus.toApi(DriverApprovalStatus.rejected),
      'REJECTED',
    );
    expect(DriverApprovalStatus.toApi(null), isNull);
  });
}
