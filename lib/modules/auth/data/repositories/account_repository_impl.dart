import 'package:dio/dio.dart';

import '../../../../core/result/result.dart';
import '../../domain/failures/account_failure.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/value_objects/signup_form.dart';
import '../datasources/account_remote_datasource.dart';
import '../mappers/account_failure_mapper.dart';

class AccountRepositoryImpl implements AccountRepository {
  AccountRepositoryImpl({required this.remote});

  final AccountRemoteDataSource remote;

  @override
  Future<Result<AccountFailure, void>> signUp(SignupForm form) {
    return runAccountRequest(() => remote.signUp(form));
  }
}

Future<Result<AccountFailure, void>> runAccountRequest(
  Future<void> Function() request,
) async {
  try {
    await request();
    return const Ok(null);
  } on DioException catch (error) {
    return Err(mapAccountFailure(error));
  }
}
