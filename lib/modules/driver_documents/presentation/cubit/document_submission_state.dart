import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/core/media/document_capture_failure.dart';
import 'package:vanep_mobile/core/media/picked_document.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/failures/document_submission_failure.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';

enum SubmissionStep { choosingSource, confirming, sending, sent, failed }

class DocumentSubmissionState extends Equatable {
  const DocumentSubmissionState({
    required this.type,
    this.vehicleToken,
    this.step = SubmissionStep.choosingSource,
    this.file,
    this.isCapturing = false,
    this.captureFailure,
    this.failure,
    this.leaveFlow = false,
    this.sentBytes = 0,
    this.totalBytes = 0,
  });

  final DocumentType type;
  final String? vehicleToken;
  final SubmissionStep step;
  final PickedDocument? file;
  final bool isCapturing;
  final DocumentCaptureFailure? captureFailure;
  final DocumentSubmissionFailure? failure;
  final bool leaveFlow;
  final int sentBytes;
  final int totalBytes;

  DocumentSubmissionState copyWith({
    SubmissionStep? step,
    PickedDocument? file,
    bool? isCapturing,
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
      step: step ?? this.step,
      file: file ?? this.file,
      isCapturing: isCapturing ?? this.isCapturing,
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
    step,
    file,
    isCapturing,
    captureFailure,
    failure,
    leaveFlow,
    sentBytes,
    totalBytes,
  ];
}
