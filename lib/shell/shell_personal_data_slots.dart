import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/user_profile.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';
import 'package:vanep_mobile/modules/auth/presentation/pages/personal_data_slots.dart';
import 'package:vanep_mobile/modules/profile/domain/profile_summary_support.dart';
import 'package:vanep_mobile/modules/profile/presentation/cubit/profile_photo_cubit.dart';
import 'package:vanep_mobile/modules/profile/presentation/cubit/profile_summary_cubit.dart';
import 'package:vanep_mobile/modules/profile/presentation/widgets/profile_photo_editor.dart';

PersonalDataSlots buildShellPersonalDataSlots(
  BuildContext context,
  UserProfile profile,
) {
  final userType = profileSummaryUserType(profile.type);
  return PersonalDataSlots(
    header: userType == null
        ? null
        : buildProfilePhotoSlot(context.read<ProfileSummaryCubit>(), userType),
  );
}

Widget buildProfilePhotoSlot(
  ProfileSummaryCubit summaryCubit,
  UserType userType,
) {
  summaryCubit.loadSummaryIfNeeded(userType);
  return MultiBlocProvider(
    providers: [
      BlocProvider<ProfileSummaryCubit>.value(value: summaryCubit),
      BlocProvider<ProfilePhotoCubit>(
        create: (_) => getIt<ProfilePhotoCubit>(),
      ),
    ],
    child: ProfilePhotoEditor(userType: userType),
  );
}
