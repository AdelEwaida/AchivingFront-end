import 'package:archiving_flutter_project/models/db/document_models/documnet_info_model.dart';
import 'package:archiving_flutter_project/models/db/document_models/upload_file_mode.dart';



class DocumentFileRequest {
  DocumentModel documentInfo;
  List<FileUploadModel> documentFile;

  DocumentFileRequest({
    required this.documentInfo,
    required this.documentFile,
  });

  // Factory method to create an instance of DocumentFileRequest from a Map
  factory DocumentFileRequest.fromJson(Map<String, dynamic> json) {
    return DocumentFileRequest(
      documentInfo: DocumentModel.fromJson(json['documentInfo']),
      documentFile: (json['documentFile'] as List)
          .map((e) => FileUploadModel.fromJson(e))
          .toList(),
    );
  }

  // Method to convert DocumentFileRequest instance to a Map
  Map<String, dynamic> toJson() {
    return {
      'documentInfo': documentInfo.toJson(),
      'documentFile': documentFile.map((e) => e.toJson()).toList(),
    };
  }
}
