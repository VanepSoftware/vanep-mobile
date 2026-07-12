import '../repositories/auth_repository.dart';
import '../value_objects/authorization_request.dart';

class BuildAuthorizationRequest {
  const BuildAuthorizationRequest(this._repository);

  final AuthRepository _repository;

  AuthorizationRequest call() => _repository.buildAuthorizationRequest();
}
