import 'package:equatable/equatable.dart';

class IbgeLocationsPage<T> extends Equatable {
  const IbgeLocationsPage({
    required this.items,
    required this.totalElements,
    required this.totalPages,
    required this.number,
    required this.size,
  });

  final List<T> items;

  final int totalElements;

  final int totalPages;

  final int number;

  final int size;

  @override
  List<Object?> get props => [items, totalElements, totalPages, number, size];
}
