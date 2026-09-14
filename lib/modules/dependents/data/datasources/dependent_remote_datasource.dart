import 'package:dio/dio.dart';

import '../../../../core/environment/environment.dart';
import '../../domain/entities/dependent.dart';
import '../../domain/value_objects/dependent_changes.dart';
import '../dtos/dependent_dto.dart';
import '../dtos/dependent_request_body.dart';

class DependentRemoteDataSource {
  DependentRemoteDataSource({required this.dio, required this.environment});

  final Dio dio;
  final Environment environment;

  String get endpoint => environment.dependentsEndpoint;

  Future<List<Dependent>> fetchMyDependents() async {
    final response = await dio.get<List<dynamic>>(endpoint);
    return readDependents(response.data);
  }

  Future<Dependent> createDependent(DependentChanges changes) async {
    final response = await dio.post<Map<String, dynamic>>(
      endpoint,
      data: dependentChangesToJson(changes),
    );
    return readDependent(response.data);
  }

  Future<Dependent> updateDependent({
    required String token,
    required DependentChanges changes,
  }) async {
    final response = await dio.patch<Map<String, dynamic>>(
      '$endpoint/$token',
      data: dependentChangesToJson(changes),
    );
    return readDependent(response.data);
  }

  Future<Dependent> markAsDefault(String token) async {
    final response = await dio.patch<Map<String, dynamic>>(
      '$endpoint/$token',
      data: const {'isDefault': true},
    );
    return readDependent(response.data);
  }
}

List<Dependent> readDependents(List<dynamic>? payload) {
  if (payload == null) return const [];
  return payload
      .whereType<Map<String, dynamic>>()
      .map((entry) => DependentDto.fromJson(Map<String, Object?>.from(entry)))
      .toList();
}

Dependent readDependent(Map<String, dynamic>? payload) {
  if (payload == null) {
    throw const FormatException('Empty dependent payload.');
  }
  return DependentDto.fromJson(Map<String, Object?>.from(payload));
}
