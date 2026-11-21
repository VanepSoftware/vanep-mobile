import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/core/media/document_capture_failure.dart';
import 'package:vanep_mobile/core/media/picked_document.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/document_submission_failure.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_draft.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/submission_target.dart';

enum SubmissionStep {
  choosingSource,
  reviewingScan,
  fillingData,
  sending,
  sent,
  failed,
}

class DocumentSubmissionState extends Equatable {
  const DocumentSubmissionState({
    required this.type,
    this.vehicleToken,
    this.target = const NewSubmission(),
    this.step = SubmissionStep.choosingSource,
    this.file,
    this.draft,
    this.isCapturing = false,
    this.isLoadingResume = false,
    this.captureFailure,
    this.failure,
    this.leaveFlow = false,
    this.sentBytes = 0,
    this.totalBytes = 0,
  });

  final DocumentType type;
  final String? vehicleToken;
  final SubmissionTarget target;
  final SubmissionStep step;
  final PickedDocument? file;
  final DocumentDraft? draft;
  final bool isCapturing;
  final bool isLoadingResume;
  final DocumentCaptureFailure? captureFailure;
  final DocumentSubmissionFailure? failure;
  final bool leaveFlow;
  final int sentBytes;
  final int totalBytes;

  DocumentSubmissionState copyWith({
    SubmissionTarget? target,
    SubmissionStep? step,
    PickedDocument? file,
    DocumentDraft? draft,
    bool? isCapturing,
    bool? isLoadingResume,
    DocumentCaptureFailure? captureFailure,
    DocumentSubmissionFailure? failure,
    bool? leaveFlow,
    int? sentBytes,
    int? totalBytes,
    bool clearCaptureFailure = false,
    bool clearFailure = false,
  }) {
    return DocumentSubmissionState(
      type: type,
      vehicleToken: vehicleToken,
      target: target ?? this.target,
      step: step ?? this.step,
      file: file ?? this.file,
      draft: draft ?? this.draft,
      isCapturing: isCapturing ?? this.isCapturing,
      isLoadingResume: isLoadingResume ?? this.isLoadingResume,
      captureFailure: clearCaptureFailure
          ? null
          : captureFailure ?? this.captureFailure,
      failure: clearFailure ? null : failure ?? this.failure,
      leaveFlow: leaveFlow ?? this.leaveFlow,
      sentBytes: sentBytes ?? this.sentBytes,
      totalBytes: totalBytes ?? this.totalBytes,
    );
  }

  @override
  List<Object?> get props => [
    type,
    vehicleToken,
    target,
    step,
    file,
    draft,
    isCapturing,
    isLoadingResume,
    captureFailure,
    failure,
    leaveFlow,
    sentBytes,
    totalBytes,
  ];
}
