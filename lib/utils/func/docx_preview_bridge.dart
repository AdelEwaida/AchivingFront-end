import 'dart:convert';
import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

class DocxPreviewBridge {
  static Future<String> convertBytesToHtml(Uint8List bytes) async {
    if (js_util.hasProperty(html.window, 'convertDocxBytesToHtml')) {
      try {
        final promise = js_util.callMethod(
          html.window,
          'convertDocxBytesToHtml',
          [base64Encode(bytes)],
        );
        if (promise != null) {
          final result = await js_util.promiseToFuture(promise);
          final htmlContent = result?.toString() ?? '';
          if (htmlContent.trim().isNotEmpty) {
            return htmlContent;
          }
        }
      } catch (_) {
        // Fall back to Dart-side extraction below.
      }
    }

    return _convertBytesToHtmlFallback(bytes);
  }

  static String _convertBytesToHtmlFallback(Uint8List bytes) {
    try {
      final archive = ZipDecoder().decodeBytes(bytes, verify: false);
      final docFile = archive.findFile('word/document.xml');
      if (docFile == null) return '<p></p>';

      final xmlDoc = XmlDocument.parse(
        utf8.decode(docFile.content as List<int>),
      );

      final buffer = StringBuffer();
      for (final paragraph in xmlDoc.findAllElements('p')) {
        final text = paragraph
            .findAllElements('t')
            .map((node) => node.innerText)
            .join();
        if (text.isNotEmpty) {
          buffer.write('<p>${_escapeHtml(text)}</p>');
        }
      }

      if (buffer.isNotEmpty) {
        return buffer.toString();
      }

      final plainText = xmlDoc
          .findAllElements('t')
          .map((node) => node.innerText)
          .join(' ')
          .trim();
      if (plainText.isEmpty) return '<p></p>';
      return '<p>${_escapeHtml(plainText)}</p>';
    } catch (_) {
      return '<p></p>';
    }
  }

  static String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;');
  }

  static String wrapHtmlDocument(String bodyHtml) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    body {
      font-family: "Segoe UI", Tahoma, Arial, sans-serif;
      font-size: 14px;
      line-height: 1.6;
      color: #1a2340;
      padding: 20px;
      margin: 0;
      background: #fff;
    }
    p { margin: 0 0 0.8em; }
    h1, h2, h3, h4 { margin: 1em 0 0.5em; }
    table { border-collapse: collapse; width: 100%; margin: 12px 0; }
    td, th { border: 1px solid #cbd5e1; padding: 6px 8px; vertical-align: top; }
    img { max-width: 100%; height: auto; }
    ul, ol { margin: 0 0 0.8em 1.4em; }
  </style>
</head>
<body>$bodyHtml</body>
</html>
''';
  }
}
