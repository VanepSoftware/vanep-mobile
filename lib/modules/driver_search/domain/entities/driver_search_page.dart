import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/driver_search/domain/entities/driver_search_result.dart';

class DriverSearchPage extends Equatable {
  const DriverSearchPage({required this.drivers, required this.isLast});

  final List<DriverSearchResult> drivers;

  final bool isLast;

  @override
  List<Object?> get props => [drivers, isLast];
}
