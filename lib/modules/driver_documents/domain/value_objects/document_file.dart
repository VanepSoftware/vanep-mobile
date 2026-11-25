import 'package:equatable/equatable.dart';

class DocumentFile extends Equatable {
  const DocumentFile({
    required this.mimeType,
    required this.sizeBytes,
    this.originalName,
  });

  final String mimeType;
  final int sizeBytes;
  final String? originalName;

  bool get isPdf => mimeType == 'application/pdf';

  @override
  List<Object?> get props => [mimeType, sizeBytes, originalName];
}
