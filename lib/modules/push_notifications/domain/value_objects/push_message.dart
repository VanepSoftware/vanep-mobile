import 'package:equatable/equatable.dart';

class PushMessage extends Equatable {
  const PushMessage({required this.data, this.title, this.body});

  final String? title;

  final String? body;

  final Map<String, Object?> data;

  bool get hasVisibleContent =>
      (title?.isNotEmpty ?? false) || (body?.isNotEmpty ?? false);

  @override
  List<Object?> get props => [title, body, data];
}
