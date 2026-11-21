import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/media/document_capture.dart';
import 'package:vanep_mobile/core/media/document_source.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/document_submission_failure.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/find_submission_for_resume.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/submit_document.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/upload_document_file.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_draft.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/submission_target.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/cubit/document_submission_state.dart';

export 'package:vanep_mobile/modules/driver_documents/presentation/cubit/document_submission_state.dart';

class DocumentSubmissionCubit extends Cubit<DocumentSubmissionState> {
  DocumentSubmissionCubit({
    required DocumentType type,
    required this.documentCapture,
    required this.submitDocument,
    required this.uploadDocumentFile,
    required this.findSubmissionForResume,
    String? vehicleToken,
  }) : super(DocumentSubmissionState(type: type, vehicleToken: vehicleToken));

  final DocumentCapture documentCapture;
  final SubmitDocument submitDocument;
  final UploadDocumentFile uploadDocumentFile;
  final FindSubmissionForResume findSubmissionForResume;

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
            step: source == DocumentSource.scanner
                ? SubmissionStep.reviewingScan
                : SubmissionStep.fillingData,
          ),
        );
    }
  }

  void continueToData() =>
      emit(state.copyWith(step: SubmissionStep.fillingData));

  Future<void> resume(String token) async {
    emit(
      state.copyWith(isLoadingResume: true, target: ExistingSubmission(token)),
    );
    final saved = await findSubmissionForResume(
      token: token,
      kind: state.type.kind,
    );
    if (isClosed) return;
    emit(switch (saved) {
      Ok(value: final draft) => state.copyWith(
        isLoadingResume: false,
        draft: draft,
      ),
      Err(:final error) => state.copyWith(
        isLoadingResume: false,
        failure: error,
      ),
    });
  }

  Future<void> submit(DocumentDraft draft) async {
    final file = state.file;
    if (file == null) return;
    emit(
      state.copyWith(
        step: SubmissionStep.sending,
        draft: draft,
        clearFailure: true,
      ),
    );
    final result = await submitDocument(
      target: state.target,
      draft: draft,
      file: file,
      onProgress: reportProgress,
    );
    if (isClosed) return;
    switch (result) {
      case Ok(value: final token):
        emit(
          state.copyWith(
            step: SubmissionStep.sent,
            target: ExistingSubmission(token),
          ),
        );
      case Err(error: FileNotSent(:final token, :final cause)):
        emit(
          state.copyWith(
            step: SubmissionStep.failed,
            target: ExistingSubmission(token),
            failure: cause,
          ),
        );
      case Err(error: DataNotSaved(:final cause)):
        emit(stateAfterRefusedData(cause));
    }
  }

  DocumentSubmissionState stateAfterRefusedData(
    DocumentSubmissionFailure cause,
  ) {
    return switch (cause) {
      NetworkSubmissionFailure() => state.copyWith(
        step: SubmissionStep.failed,
        failure: cause,
      ),
      PendingExistsFailure() || AlreadyReviewedFailure() => state.copyWith(
        step: SubmissionStep.fillingData,
        failure: cause,
        leaveFlow: true,
      ),
      _ => state.copyWith(step: SubmissionStep.fillingData, failure: cause),
    };
  }

  Future<void> retry() async {
    final draft = state.draft;
    final target = state.target;
    final file = state.file;
    if (draft == null || file == null) return;
    if (target is! ExistingSubmission) return submit(draft);
    emit(state.copyWith(step: SubmissionStep.sending, clearFailure: true));
    final sent = await uploadDocumentFile(
      token: target.token,
      kind: state.type.kind,
      file: file,
      onProgress: reportProgress,
    );
    if (isClosed) return;
    emit(switch (sent) {
      Ok() => state.copyWith(step: SubmissionStep.sent),
      Err(:final error) => state.copyWith(
        step: SubmissionStep.failed,
        failure: error,
      ),
    });
  }

  void reviewData() => emit(
    state.copyWith(step: SubmissionStep.fillingData, clearFailure: true),
  );

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
