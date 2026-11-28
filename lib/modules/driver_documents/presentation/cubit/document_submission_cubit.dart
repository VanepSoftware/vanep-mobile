import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/media/document_capture.dart';
import 'package:vanep_mobile/core/media/document_source.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/document_submission_failure.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/submit_document.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_upload.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/cubit/document_submission_state.dart';

export 'package:vanep_mobile/modules/driver_documents/presentation/cubit/document_submission_state.dart';

class DocumentSubmissionCubit extends Cubit<DocumentSubmissionState> {
  DocumentSubmissionCubit({
    required DocumentType type,
    required this.documentCapture,
    required this.submitDocument,
    String? vehicleToken,
  }) : super(DocumentSubmissionState(type: type, vehicleToken: vehicleToken));

  final DocumentCapture documentCapture;
  final SubmitDocument submitDocument;

  Future<void> capture(DocumentSource source) async {
    emit(state.copyWith(isCapturing: true, clearCaptureFailure: true));
    final captured = await documentCapture.capture(source);
    if (isClosed) return;
    switch (captured) {
      case Err(:final error):
        emit(state.copyWith(isCapturing: false, captureFailure: error));
      case Ok(value: null):
        emit(state.copyWith(isCapturing: false));
      case Ok(value: final file?):
        emit(
          state.copyWith(
            isCapturing: false,
            file: file,
            clearFailure: true,
            step: SubmissionStep.confirming,
          ),
        );
    }
  }

  Future<void> submit() async {
    final file = state.file;
    if (file == null) return;
    emit(
      state.copyWith(
        step: SubmissionStep.sending,
        clearFailure: true,
        sentBytes: 0,
        totalBytes: 0,
      ),
    );
    final result = await submitDocument(
      DocumentUpload(
        type: state.type,
        vehicleToken: state.vehicleToken,
        file: file,
      ),
      onProgress: reportProgress,
    );
    if (isClosed) return;
    emit(switch (result) {
      Ok() => state.copyWith(step: SubmissionStep.sent),
      Err(:final error) => stateAfterRefusal(error),
    });
  }

  DocumentSubmissionState stateAfterRefusal(DocumentSubmissionFailure cause) {
    return switch (cause) {
      NetworkSubmissionFailure() => state.copyWith(
        step: SubmissionStep.failed,
        failure: cause,
      ),
      PendingExistsFailure() || AlreadyReviewedFailure() => state.copyWith(
        step: SubmissionStep.confirming,
        failure: cause,
        leaveFlow: true,
      ),
      _ => state.copyWith(step: SubmissionStep.confirming, failure: cause),
    };
  }

  void clearMessages() => emit(
    state.copyWith(
      clearCaptureFailure: true,
      clearFailure: true,
      leaveFlow: false,
    ),
  );

  void reportProgress(int sentBytes, int totalBytes) {
    if (isClosed) return;
    emit(state.copyWith(sentBytes: sentBytes, totalBytes: totalBytes));
  }
}
