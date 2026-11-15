import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/entities/van_assistant.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/failures/van_central_failure.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/repositories/van_central_repository.dart';

class ListVanAssistants {
  const ListVanAssistants(this.repository);

  final VanCentralRepository repository;

  Future<Result<VanCentralFailure, List<VanAssistant>>> call() {
    return repository.listAssistants();
  }
}
