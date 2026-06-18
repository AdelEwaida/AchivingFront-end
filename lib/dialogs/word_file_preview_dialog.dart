import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;

import 'package:archiving_flutter_project/utils/func/docx_preview_bridge.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/utils/func/save_excel_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'app_dialog.dart';

class WordFilePreviewDialog extends StatefulWidget {
  final Uint8List bytes;
  final String fileName;

  const WordFilePreviewDialog({
    super.key,
    required this.bytes,
    required this.fileName,
  });

  @override
  State<WordFilePreviewDialog> createState() => _WordFilePreviewDialogState();
}

class _WordFilePreviewDialogState extends State<WordFilePreviewDialog> {
  String? _viewType;
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  Future<void> _loadPreview() async {
    final isDocx = widget.fileName.toLowerCase().endsWith('.docx');
    if (!isDocx) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = null;
        _viewType = null;
      });
      return;
    }

    try {
      final bodyHtml = await DocxPreviewBridge.convertBytesToHtml(widget.bytes);
      if (!mounted) return;

      final viewType = 'word-preview-${identityHashCode(this)}';
      final srcDoc = DocxPreviewBridge.wrapHtmlDocument(bodyHtml);

      ui_web.platformViewRegistry.registerViewFactory(
        viewType,
        (int viewId) {
          final iframe = html.IFrameElement()
            ..setAttribute('srcdoc', srcDoc)
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%';
          return iframe;
        },
      );

      setState(() {
        _viewType = viewType;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isDesktop = Responsive.isDesktop(context);

    return AppDialog(
      width: isDesktop ? width * 0.55 : width * 0.92,
      height: height * 0.82,
      title: Row(
        children: [
          Expanded(
            child: Text(
              locale.previewFile,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            tooltip: locale.download,
            onPressed: () => saveExcelFile(widget.bytes, widget.fileName),
            icon: const Icon(Icons.download, color: Colors.white, size: 18),
          ),
        ],
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.fileName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFDDE3EE)),
                  color: const Color(0xFFF8FAFC),
                ),
                child: _buildBody(locale),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AppLocalizations locale) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF185FA5)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
        ),
      );
    }

    if (_viewType == null && _errorMessage == null) {
      return Center(
        child: Text(
          locale.previewNotAvilable,
          style: const TextStyle(color: Color(0xFF64748B)),
        ),
      );
    }

    return HtmlElementView(viewType: _viewType!);
  }
}
