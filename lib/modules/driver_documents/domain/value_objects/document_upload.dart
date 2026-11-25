import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/core/media/picked_document.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';

class DocumentUpload extends Equatable {
  const DocumentUpload({
    required this.type,
    required this.file,
    this.vehicleToken,
  });

  final DocumentType type;
  final PickedDocument file;
  final String? vehicleToken;

  @override
  List<Object?> get props => [type, file, vehicleToken];
}
