import 'package:equatable/equatable.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_van.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';

class AssistantVanSelectorState extends Equatable {
  const AssistantVanSelectorState({
    this.isLoading = false,
    this.vans = const [],
    this.selectedVan,
    this.failure,
  });

  final bool isLoading;

  final List<AssistantVan> vans;

  final AssistantVan? selectedVan;

  final AssistantFailure? failure;

  bool get hasMultipleVans => vans.length > 1;

  bool get hasActiveVan => selectedVan != null;

  AssistantVanSelectorState copyWith({
    bool? isLoading,
    List<AssistantVan>? vans,
    AssistantVan? Function()? selectedVan,
    AssistantFailure? Function()? failure,
  }) {
    return AssistantVanSelectorState(
      isLoading: isLoading ?? this.isLoading,
      vans: vans ?? this.vans,
      selectedVan: selectedVan != null ? selectedVan() : this.selectedVan,
      failure: failure != null ? failure() : this.failure,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    vans,
    selectedVan,
    failure,
  ];
}
