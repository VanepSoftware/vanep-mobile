import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/media/file_opener.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/download_document_file.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_file.dart';

const String unnamedPdfFileName = 'documento.pdf';

class DocumentFileState extends Equatable {
  const DocumentFileState({
    this.isOpening = false,
    this.imageUrl,
    this.failed = false,
  });

  final bool isOpening;
  final String? imageUrl;
  final bool failed;

  @override
  List<Object?> get props => [isOpening, imageUrl, failed];
}

class DocumentFileCubit extends Cubit<DocumentFileState> {
  DocumentFileCubit({
    required this.downloadDocumentFile,
    required this.fileOpener,
  }) : super(const DocumentFileState());

  final DownloadDocumentFile downloadDocumentFile;
  final FileOpener fileOpener;

  Future<void> open(String fileUrl, DocumentFile file) async {
    if (!file.isPdf) {
      emit(DocumentFileState(imageUrl: fileUrl));
      return;
    }
    emit(const DocumentFileState(isOpening: true));
    final downloaded = await downloadDocumentFile(
      fileUrl,
      fileName: file.originalName ?? unnamedPdfFileName,
    );
    final opened = switch (downloaded) {
      Ok(value: final path) => await fileOpener.open(path),
      Err() => false,
    };
    if (isClosed) return;
    emit(DocumentFileState(failed: !opened));
  }

  void clear() => emit(const DocumentFileState());
}
