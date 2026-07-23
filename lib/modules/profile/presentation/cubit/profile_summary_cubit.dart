import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/value_objects/user_type.dart';
import '../../domain/entities/profile_summary.dart';
import '../../domain/failures/profile_summary_failure.dart';
import '../../domain/profile_summary_support.dart';
import '../../domain/usecases/get_profile_summary.dart';

enum ProfileSummaryStatus { initial, loading, loaded }

class ProfileSummaryState extends Equatable {
  const ProfileSummaryState({
    this.status = ProfileSummaryStatus.initial,
    this.summary,
    this.failure,
  });

  final ProfileSummaryStatus status;
  final ProfileSummary? summary;
  final ProfileSummaryFailure? failure;

  String? get photoUrl => summary?.photoUrl;

  @override
  List<Object?> get props => [status, summary, failure];
}

class ProfileSummaryCubit extends Cubit<ProfileSummaryState> {
  ProfileSummaryCubit({required this.getProfileSummary})
    : super(const ProfileSummaryState());

  final GetProfileSummary getProfileSummary;

  Future<void> loadSummaryIfNeeded(UserType? type) async {
    if (state.status != ProfileSummaryStatus.initial) return;

    final summaryType = profileSummaryUserType(type);
    if (summaryType == null) {
      emit(const ProfileSummaryState(status: ProfileSummaryStatus.loaded));
      return;
    }

    emit(const ProfileSummaryState(status: ProfileSummaryStatus.loading));
    final result = await getProfileSummary(summaryType);
    result.fold(
      (failure) => emit(
        ProfileSummaryState(
          status: ProfileSummaryStatus.loaded,
          failure: failure,
        ),
      ),
      (summary) => emit(
        ProfileSummaryState(
          status: ProfileSummaryStatus.loaded,
          summary: summary,
        ),
      ),
    );
  }
}
