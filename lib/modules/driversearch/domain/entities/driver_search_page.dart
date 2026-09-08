import 'package:equatable/equatable.dart';

import 'driver_search_result.dart';

class DriverSearchPage extends Equatable {
  const DriverSearchPage({required this.drivers, required this.isLast});

  final List<DriverSearchResult> drivers;

  final bool isLast;

  @override
  List<Object?> get props => [drivers, isLast];
}
