import 'dart:typed_data';
import 'dart:html' as html;

import 'package:archiving_flutter_project/utils/func/converters.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// metode using in all page , to save excel files
void saveExcelFile(Uint8List byteList, String fileName) {
  final blob = html.Blob([byteList]);
  final url = html.Url.createObjectUrlFromBlob(blob);

  final anchor = html.AnchorElement(href: url)
    ..target = 'blank'
    ..download =
        "$fileName ${Converters.formatDate(DateTime.now().toString())}.xlsx"
    ..click();

  html.Url.revokeObjectUrl(url);
}
