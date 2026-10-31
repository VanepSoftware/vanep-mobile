import 'package:equatable/equatable.dart';

class NegotiationPage<T> extends Equatable {
  const NegotiationPage({
    required this.items,
    required this.isLast,
    required this.totalElements,
  });

  final List<T> items;

  final bool isLast;

  final int totalElements;

  @override
  List<Object?> get props => [items, isLast, totalElements];
}
