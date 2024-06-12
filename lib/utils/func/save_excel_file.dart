import 'dart:async';
import 'dart:typed_data';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:js' as js;

import 'package:archiving_flutter_project/utils/func/converters.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// metode using in all page , to save excel files
void saveExcelFile(Uint8List byteList, String fileName) {
  final blob = html.Blob([byteList]);
  final url = html.Url.createObjectUrlFromBlob(blob);

  final anchor = html.AnchorElement(href: url)
    ..target = 'blank'
    ..download = "${Converters.formatDate(DateTime.now().toString())} $fileName"
    ..click();

  html.Url.revokeObjectUrl(url);
}

Future<Uint8List> blobToUint8List(html.Blob blob) async {
  final completer = Completer<Uint8List>();

  // Create a FileReader object
  final reader = html.FileReader();

  // Set up onload callback
  reader.onLoad.listen((event) {
    completer.complete(reader.result as Uint8List);
  });

  // Set up onerror callback
  reader.onError.listen((error) {
    completer.completeError(error);
  });

  // Read the Blob content as ArrayBuffer
  reader.readAsArrayBuffer(blob);

  return completer.future;
}
