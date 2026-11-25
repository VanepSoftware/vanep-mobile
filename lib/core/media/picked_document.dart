import 'package:equatable/equatable.dart';

class PickedDocument extends Equatable {
  const PickedDocument({
    required this.path,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    this.pageCount,
    this.pagePreviewPaths = const [],
  });

  final String path;
  final String fileName;
  final String mimeType;
  final int sizeBytes;
  final int? pageCount;
  final List<String> pagePreviewPaths;

  @override
  List<Object?> get props => [
    path,
    fileName,
    mimeType,
    sizeBytes,
    pageCount,
    pagePreviewPaths,
  ];
}
