import 'documnet_info_model.dart';
import 'upload_file_mode.dart';

class DocumentFileRequest {
  DocumentModel documentInfo;
  FileUploadModel documentFile;

  DocumentFileRequest({
    required this.documentInfo,
    required this.documentFile,
  });

  // Factory method to create an instance of DocumentFileRequest from a Map
  factory DocumentFileRequest.fromJson(Map<String, dynamic> json) {
    return DocumentFileRequest(
      documentInfo: DocumentModel.fromJson(json['documentInfo']),
      documentFile: FileUploadModel.fromJson(json['documentFile']),
    );
  }

  // Method to convert DocumentFileRequest instance to a Map
  Map<String, dynamic> toJson() {
    return {
      'documentInfo': documentInfo,
      'documentFile': documentFile,
    };
  }
}
