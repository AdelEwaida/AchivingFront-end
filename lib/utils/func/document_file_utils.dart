import 'dart:typed_data';

import 'package:archiving_flutter_project/models/db/document_models/upload_file_mode.dart';
import 'package:flutter/material.dart';

import '../../dialogs/pdf_preview.dart';
import '../../dialogs/word_file_preview_dialog.dart';

class DocumentFileUtils {
  static const imageExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.bmp',
    '.webp',
    '.tif',
    '.tiff',
  ];

  static const wordExtensions = [
    '.docx',
    '.doc',
  ];

  static const videoExtensions = [
    '.mp4',
    '.avi',
    '.mov',
    '.wmv',
    '.flv',
    '.mkv',
    '.webm',
    '.mpeg',
    '.mpg',
    '.m4v',
    '.3gp',
    '.ogv',
    '.ts',
  ];

  static const audioExtensions = [
    '.mp3',
    '.wav',
    '.aac',
    '.ogg',
    '.wma',
    '.m4a',
    '.flac',
  ];

  static const int maxUploadSizeMb = 2000;
  static const int maxUploadSizeBytes = maxUploadSizeMb * 1024 * 1024;

  static String fileNameLower(String? name) => (name ?? '').trim().toLowerCase();

  static bool endsWithAny(String name, List<String> extensions) {
    return extensions.any((ext) => name.endsWith(ext));
  }

  static bool isImageFileName(String? name) {
    final lower = fileNameLower(name);
    return endsWithAny(lower, imageExtensions);
  }

  static bool isPdfFileName(String? name) {
    return fileNameLower(name).endsWith('.pdf');
  }

  static bool isWordFileName(String? name) {
    return endsWithAny(fileNameLower(name), wordExtensions);
  }

  static bool isVideoFileName(String? name) {
    return endsWithAny(fileNameLower(name), videoExtensions);
  }

  static bool isAudioFileName(String? name) {
    return endsWithAny(fileNameLower(name), audioExtensions);
  }

  static bool isBlockedUploadFileName(String? name) {
    return isVideoFileName(name) || isAudioFileName(name);
  }

  static bool isFileSizeAllowed(int sizeInBytes) {
    return sizeInBytes <= maxUploadSizeBytes;
  }

  static String formatSelectedFileNames(List<String> names) {
    if (names.isEmpty) return '';
    return names.join(', ');
  }

  static bool isImageFile(FileUploadModel file) {
    final mime = (file.txtMimetype ?? '').toLowerCase();
    if (mime.startsWith('image/')) return true;
    return isImageFileName(file.txtFilename);
  }

  static bool isPdfFile(FileUploadModel file) {
    final mime = (file.txtMimetype ?? '').toLowerCase();
    return mime.contains('pdf') || isPdfFileName(file.txtFilename);
  }

  static bool isWordFile(FileUploadModel file) {
    final mime = (file.txtMimetype ?? '').toLowerCase();
    if (mime.contains('word') ||
        mime.contains('msword') ||
        mime.contains('wordprocessingml')) {
      return true;
    }
    return isWordFileName(file.txtFilename);
  }

  static bool canPreviewInApp(String? fileName) {
    return isPdfFileName(fileName) ||
        isImageFileName(fileName) ||
        isWordFileName(fileName);
  }

  static void showPreviewDialog(
    BuildContext context, {
    required Uint8List bytes,
    required String fileName,
  }) {
    if (isWordFileName(fileName)) {
      showDialog(
        context: context,
        builder: (_) => WordFilePreviewDialog(
          bytes: bytes,
          fileName: fileName,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => PdfPreview1(
        pdfFile: bytes,
        fileName: fileName,
      ),
    );
  }
}
