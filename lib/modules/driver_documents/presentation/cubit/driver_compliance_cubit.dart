import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/load_my_compliance.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/cubit/driver_compliance_state.dart';

export 'package:vanep_mobile/modules/driver_documents/presentation/cubit/driver_compliance_state.dart';

class DriverComplianceCubit extends Cubit<DriverComplianceState> {
  DriverComplianceCubit({required this.loadMyCompliance})
    : super(const DriverComplianceState.loading());

  final LoadMyCompliance loadMyCompliance;

  Future<void> load() async {
    emit(const DriverComplianceState.loading());
    final result = await loadMyCompliance();
    if (isClosed) return;
    emit(switch (result) {
      Ok(:final value) => DriverComplianceState.ready(value),
      Err(:final error) => DriverComplianceState.failed(error),
    });
  }

  Future<void> refresh() async {
    final result = await loadMyCompliance();
    if (isClosed) return;
    switch (result) {
      case Ok(:final value):
        emit(DriverComplianceState.ready(value));
      case Err(:final error):
        if (state.compliance == null) emit(DriverComplianceState.failed(error));
    }
  }
}
