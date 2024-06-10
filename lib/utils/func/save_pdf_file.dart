import 'dart:convert';
import 'dart:html';

Future downloadPdfFile(
  List<int> bytes,
  String downloadName,
) async {
  // Encode our file in base64
  print(1);
  final _base64 = base64Encode(bytes);
  print(2);

  // Create the link with the file
  final anchor =
      AnchorElement(href: 'data:application/octet-stream;base64,$_base64')
        ..target = 'blank';
  // add the name
  print(3);

  anchor.download = downloadName;
  print(4);

  // trigger download
  document.body!.append(anchor);
  print(5);

  anchor.click();
  anchor.remove();
  return;
}
