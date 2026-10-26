import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/client_home/domain/failures/client_home_failure.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/client_home.dart';

enum ClientHomeStatus { initial, loading, ready, loadFailed }

class ClientHomeState extends Equatable {
  const ClientHomeState({
    this.status = ClientHomeStatus.initial,
    this.home,
    this.failure,
  });

  final ClientHomeStatus status;

  final ClientHome? home;

  final ClientHomeFailure? failure;

  bool get hasLoadFailed => status == ClientHomeStatus.loadFailed;

  bool get showsSkeleton => home == null && !hasLoadFailed;

  @override
  List<Object?> get props => [status, home, failure];
}
