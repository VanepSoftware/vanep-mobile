import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/core/media/document_file_store.dart';
import 'package:vanep_mobile/core/network/dio_client.dart';
import 'package:vanep_mobile/core/network/file_uploader.dart';
import 'package:vanep_mobile/modules/driver_documents/data/datasources/driver_documents_remote_datasource.dart';
import 'package:vanep_mobile/modules/driver_documents/data/repositories/document_submission_repository_impl.dart';
import 'package:vanep_mobile/modules/driver_documents/data/repositories/driver_compliance_repository_impl.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/repositories/document_submission_repository.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/repositories/driver_compliance_repository.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/download_document_file.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/find_submission_for_resume.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/load_my_compliance.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/submit_document.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/upload_document_file.dart';
import 'package:vanep_mobile/modules/driver_documents/presentation/cubit/driver_compliance_cubit.dart';

void registerDriverDocumentsDependencies(GetIt getIt) {
  getIt
    ..registerSingleton<DriverDocumentsRemoteDataSource>(
      DriverDocumentsRemoteDataSource(
        dio: getIt<Dio>(instanceName: authenticatedDioName),
        environment: getIt<Environment>(),
        fileUploader: getIt<FileUploader>(),
      ),
    )
    ..registerSingleton<DriverComplianceRepository>(
      DriverComplianceRepositoryImpl(getIt<DriverDocumentsRemoteDataSource>()),
    )
    ..registerSingleton<DocumentSubmissionRepository>(
      DocumentSubmissionRepositoryImpl(
        getIt<DriverDocumentsRemoteDataSource>(),
        getIt<DocumentFileStore>(),
      ),
    )
    ..registerFactory<LoadMyCompliance>(
      () => LoadMyCompliance(getIt<DriverComplianceRepository>()),
    )
    ..registerFactory<SubmitDocument>(
      () => SubmitDocument(getIt<DocumentSubmissionRepository>()),
    )
    ..registerFactory<UploadDocumentFile>(
      () => UploadDocumentFile(getIt<DocumentSubmissionRepository>()),
    )
    ..registerFactory<FindSubmissionForResume>(
      () => FindSubmissionForResume(getIt<DocumentSubmissionRepository>()),
    )
    ..registerFactory<DownloadDocumentFile>(
      () => DownloadDocumentFile(getIt<DocumentSubmissionRepository>()),
    )
    ..registerFactory<DriverComplianceCubit>(
      () => DriverComplianceCubit(loadMyCompliance: getIt<LoadMyCompliance>()),
    );
}
