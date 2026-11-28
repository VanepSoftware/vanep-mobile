import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/assistant_remote_datasource.dart';
import 'package:vanep_mobile/modules/assistant/data/repositories/assistant_repository_impl.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_students_repository.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_students_overview.dart';

class AssistantStudentsRepositoryImpl implements AssistantStudentsRepository {
  const AssistantStudentsRepositoryImpl({required this.remote});

  final AssistantRemoteDataSource remote;

  /// One roster per shift from /api/assistants/me/vans, each filled from
  /// /me/vans/{vanToken}/students?shift=...
  @override
  Future<Result<AssistantFailure, AssistantStudentsOverview>>
  findStudentsOverview() {
    return guardAssistantCall(() async {
      final shifts = [
        for (final summary in await remote.fetchVanSummaries())
          if (summary.van.shift != null) summary.van,
      ];
      final students = await Future.wait([
        for (final van in shifts) remote.fetchStudents(van.token, van.shift!),
      ]);
      return AssistantStudentsOverview(
        rosters: [
          for (final (index, van) in shifts.indexed)
            AssistantStudentsRoster(van: van, students: students[index]),
        ],
      );
    });
  }
}
