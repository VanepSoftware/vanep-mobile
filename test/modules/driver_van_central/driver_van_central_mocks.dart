import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/driver_van_central/data/datasources/van_central_remote_datasource.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/repositories/van_central_repository.dart';

class MockDio extends Mock implements Dio {}

class MockVanCentralRemoteDataSource extends Mock
    implements VanCentralRemoteDataSource {}

class MockVanCentralRepository extends Mock implements VanCentralRepository {}
