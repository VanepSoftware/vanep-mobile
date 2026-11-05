import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/personal_address_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/find_my_personal_address.dart';
import 'package:vanep_mobile/modules/client_home/domain/failures/client_home_failure.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/today_section.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/find_my_dependents.dart';

ClientHomeFailure clientHomeFailureFromAddress(PersonalAddressFailure failure) {
  return failure == PersonalAddressFailure.network
      ? ClientHomeFailure.network
      : ClientHomeFailure.unexpected;
}

ClientHomeFailure clientHomeFailureFromDependents(DependentFailure failure) {
  return failure is DependentNetworkFailure
      ? ClientHomeFailure.network
      : ClientHomeFailure.unexpected;
}

TodaySection sectionForOnboarding({
  required bool hasAddress,
  required bool hasDependents,
}) {
  final steps = FirstStepsSection(
    hasAddress: hasAddress,
    hasDependents: hasDependents,
  );
  return steps.isComplete ? const NoLinkedVanSection() : steps;
}

class ResolveSectionWithoutVan {
  const ResolveSectionWithoutVan({
    required this.findMyPersonalAddress,
    required this.findMyDependents,
  });

  final FindMyPersonalAddress findMyPersonalAddress;

  final FindMyDependents findMyDependents;

  Future<Result<ClientHomeFailure, TodaySection>> call() async {
    final (addressResult, dependentsResult) = await (
      findMyPersonalAddress(),
      findMyDependents(),
    ).wait;

    final addressFailure = addressResult.errorOrNull;
    if (addressFailure != null) {
      return Err(clientHomeFailureFromAddress(addressFailure));
    }
    final dependentsFailure = dependentsResult.errorOrNull;
    if (dependentsFailure != null) {
      return Err(clientHomeFailureFromDependents(dependentsFailure));
    }

    return Ok(
      sectionForOnboarding(
        hasAddress: addressResult.valueOrNull != null,
        hasDependents: dependentsResult.valueOrNull?.isNotEmpty ?? false,
      ),
    );
  }
}
