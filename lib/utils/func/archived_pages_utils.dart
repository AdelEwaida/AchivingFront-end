import 'package:archiving_flutter_project/models/db/document_models/upload_file_mode.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'converters.dart';

class ArchivedPagesUtils {
  static const _imageExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.bmp',
    '.webp',
    '.tif',
    '.tiff',
  ];

  static bool isImageFile(FileUploadModel file) {
    final name = (file.txtFilename ?? '').toLowerCase();
    final mime = (file.txtMimetype ?? '').toLowerCase();
    if (mime.startsWith('image/')) return true;
    return _imageExtensions.any(name.endsWith);
  }

  static bool isPdfFile(FileUploadModel file) {
    final name = (file.txtFilename ?? '').toLowerCase();
    final mime = (file.txtMimetype ?? '').toLowerCase();
    return mime.contains('pdf') || name.endsWith('.pdf');
  }

  static int countPagesForFile(FileUploadModel file) {
    if (isImageFile(file)) return 1;
    if (!isPdfFile(file)) return 0;

    final bytes = Converters.decodeDocumentImgBlob(file.imgBlob);
    if (bytes == null || bytes.isEmpty) return 0;

    PdfDocument? document;
    try {
      document = PdfDocument(inputBytes: bytes);
      return document.pages.count;
    } catch (_) {
      return 0;
    } finally {
      document?.dispose();
    }
  }

  static int countArchivedPages(List<FileUploadModel> files) {
    var total = 0;
    for (final file in files) {
      total += countPagesForFile(file);
    }
    return total;
  }
}
