import 'dart:convert';
import 'dart:typed_data';

import 'package:archiving_flutter_project/models/db/document_models/upload_file_mode.dart';
import 'package:archive/archive.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'converters.dart';
import 'document_file_utils.dart';

class ArchivedPagesUtils {
  static int countPagesForFile(FileUploadModel file) {
    if (DocumentFileUtils.isImageFile(file)) return 1;
    if (DocumentFileUtils.isPdfFile(file)) return _countPdfPages(file);
    if (DocumentFileUtils.isWordFile(file)) return _countWordPages(file);
    return 0;
  }

  static int countArchivedPages(List<FileUploadModel> files) {
    var total = 0;
    for (final file in files) {
      total += countPagesForFile(file);
    }
    return total;
  }

  static int _countPdfPages(FileUploadModel file) {
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

  static int _countWordPages(FileUploadModel file) {
    final bytes = Converters.decodeDocumentImgBlob(file.imgBlob);
    if (bytes == null || bytes.isEmpty) return 0;

    final name = DocumentFileUtils.fileNameLower(file.txtFilename);
    if (name.endsWith('.docx')) {
      return _countDocxPages(bytes);
    }
    if (name.endsWith('.doc')) {
      return _countLegacyDocPages(bytes);
    }
    return 0;
  }

  static int _countDocxPages(Uint8List bytes) {
    try {
      final archive = ZipDecoder().decodeBytes(bytes, verify: false);

      final appFile = archive.findFile('docProps/app.xml');
      if (appFile != null) {
        final xml = utf8.decode(appFile.content as List<int>);
        final pagesMatch = RegExp(r'<Pages>(\d+)</Pages>').firstMatch(xml);
        if (pagesMatch != null) {
          final pages = int.tryParse(pagesMatch.group(1)!);
          if (pages != null && pages > 0) return pages;
        }
      }

      final docFile = archive.findFile('word/document.xml');
      if (docFile != null) {
        final xml = utf8.decode(docFile.content as List<int>);
        if (xml.trim().isEmpty) return 0;

        var pageBreaks = 0;
        pageBreaks += RegExp(r'w:type="page"').allMatches(xml).length;
        pageBreaks += RegExp(r'lastRenderedPageBreak').allMatches(xml).length;
        return pageBreaks + 1;
      }
    } catch (_) {}

    return 0;
  }

  static int _countLegacyDocPages(Uint8List bytes) {
    if (bytes.isEmpty) return 0;

    var formFeeds = 0;
    for (final byte in bytes) {
      if (byte == 0x0C) formFeeds++;
    }
    if (formFeeds > 0) return formFeeds + 1;

    return 1;
  }
}
