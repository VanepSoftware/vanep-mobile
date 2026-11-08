import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/core/network/postal_address_body.dart';
import 'package:vanep_mobile/core/domain/postal_address_draft.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/unlinked_passenger_draft.dart';

Map<String, Object?> unlinkedPassengerSlotToJson(UnlinkedPassengerSlot slot) {
  return {
    'weekday': Weekday.toApi(slot.weekday),
    'leg': slot.leg.apiName,
    'shift': slot.shift.apiName,
    'pickupTime': slot.pickupTime.toApi(),
  };
}

Map<String, Object?> unlinkedPassengerDraftToJson(
  UnlinkedPassengerDraft draft,
) {
  final address = draft.address;
  return {
    'name': draft.name.trim(),
    'schoolToken': draft.school?.token,
    'schoolShift': SchoolShift.toApi(draft.schoolShift),
    'address': postalAddressToJson(
      cityToken: address.cityToken,
      street: address.street,
      zipCode: address.zipCode,
      number: address.number,
      complement: address.complement,
      neighborhood: address.neighborhood,
    ),
    'notes': blankToNull(draft.notes),
    'slots': [
      for (final slot in draft.slots) unlinkedPassengerSlotToJson(slot),
    ],
    'vehicleToken': ?draft.vehicleToken,
  };
}
