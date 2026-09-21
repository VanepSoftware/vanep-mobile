import 'package:vanep_mobile/core/domain/postal_address_draft.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/personal_address.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/user_profile.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/personal_data_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/personal_data_state.dart';

import '../auth_fixtures.dart';

PersonalDataState readyState({
  UserProfile profile = const FakeUserProfile(),
  PersonalAddress? address,
  PostalAddressDraft? addressDraft,
}) {
  final base = stateFromProfile(
    profile,
    status: PersonalDataStatus.ready,
    address: address,
  );
  return addressDraft == null
      ? base
      : base.copyWith(addressDraft: addressDraft);
}
