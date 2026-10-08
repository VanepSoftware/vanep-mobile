import 'package:equatable/equatable.dart';

class PickedPhoto extends Equatable {
  const PickedPhoto({required this.path, required this.fileName});

  final String path;
  final String fileName;

  @override
  List<Object?> get props => [path, fileName];
}
