const int _bytesInMegabyte = 1024 * 1024;

// Must match the back's `vanep.media.max-document-size-mb`, which counts
// megabytes the same way.
const int documentUploadLimitBytes = 10 * _bytesInMegabyte;

bool isWithinDocumentUploadLimit(int sizeBytes) =>
    sizeBytes <= documentUploadLimitBytes;
