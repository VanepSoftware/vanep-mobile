import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/value_objects/van_registration.dart';

import '../driver_vans_fixtures.dart';

void main() {
  test('a complete van has no errors', () {
    expect(validRegistration.validate(), isEmpty);
  });

  test('every empty field is required', () {
    expect(const VanRegistration().validate(), {
      for (final field in VanField.values) field: VanFieldError.required,
    });
  });

  test('accepts the old and the Mercosul plate, with or without dash', () {
    for (final plate in ['ABC1234', 'ABC-1234', 'abc1d23', 'ABC-1D23']) {
      expect(
        validRegistration.copyWithField(VanField.plate, plate).validate(),
        isEmpty,
        reason: plate,
      );
    }
  });

  test('rejects a plate in any other shape', () {
    expect(
      validRegistration.copyWithField(VanField.plate, 'AB12345').validate(),
      {VanField.plate: VanFieldError.invalid},
    );
  });

  test('rejects a year out of range and a van with no seats', () {
    final registration = validRegistration
        .copyWithField(VanField.manufactureYear, '1899')
        .copyWithField(VanField.capacity, '0');

    expect(registration.validate(), {
      VanField.manufactureYear: VanFieldError.invalid,
      VanField.capacity: VanFieldError.invalid,
    });
  });

  test('changing one field keeps the others', () {
    final changed = validRegistration.copyWithField(VanField.color, 'Prata');

    expect(changed.color, 'Prata');
    expect(changed.model, 'Sprinter');
    expect(changed.valueOf(VanField.capacity), '15');
  });
}
