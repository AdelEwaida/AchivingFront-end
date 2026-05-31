import 'package:archiving_flutter_project/providers/file_list_provider.dart';
import 'package:archiving_flutter_project/providers/local_provider.dart';
import 'package:archiving_flutter_project/providers/screen_content_provider.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/voice_assistant/archive_voice_assistant.dart';
import 'package:archiving_flutter_project/voice_assistant/assistant_search_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VoiceAssistantFab extends StatefulWidget {
  const VoiceAssistantFab({super.key});

  @override
  State<VoiceAssistantFab> createState() => _VoiceAssistantFabState();
}

enum _ChatStep { chooseField, enterValue }

class _ChatMessage {
  _ChatMessage({
    required this.isUser,
    required this.text,
    this.showFieldChoices = false,
  });

  final bool isUser;
  final String text;
  final bool showFieldChoices;
}

class _VoiceAssistantFabState extends State<VoiceAssistantFab> {
  final TextEditingController _textInput = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _panelOpen = false;
  _ChatStep _step = _ChatStep.chooseField;
  AssistantSearchField? _selectedField;
  final List<_ChatMessage> _messages = [];

  bool get _isArabic =>
      ArchiveVoiceAssistant.isArabicUi(context.read<LocaleProvider>().locale);

  @override
  void dispose() {
    _textInput.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _resetConversation() {
    setState(() {
      _step = _ChatStep.chooseField;
      _selectedField = null;
      _messages.clear();
      _messages.add(_ChatMessage(
        isUser: false,
        text: ArchiveVoiceAssistant.welcomeMessage(_isArabic),
        showFieldChoices: true,
      ));
    });
    _scrollToEnd();
  }

  void _openPanel() {
    setState(() {
      _panelOpen = true;
      if (_messages.isEmpty) _resetConversation();
    });
  }

  void _closePanel() {
    setState(() => _panelOpen = false);
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void _addBot(String text, {bool showChoices = false}) {
    setState(() {
      _messages.add(_ChatMessage(
        isUser: false,
        text: text,
        showFieldChoices: showChoices,
      ));
    });
    _scrollToEnd();
  }

  void _addUser(String text) {
    setState(() {
      _messages.add(_ChatMessage(isUser: true, text: text));
    });
    _scrollToEnd();
  }

  void _onFieldSelected(AssistantSearchField field) {
    final info = fieldInfo(field);
    _selectedField = field;
    _step = _ChatStep.enterValue;
    _addUser(info.label(_isArabic));
    _addBot(info.valuePrompt(_isArabic));
    _textInput.clear();
  }

  void _submitValue() {
    final value = _textInput.text.trim();
    if (value.isEmpty || _selectedField == null) return;

    _textInput.clear();
    _addUser(value);

    final confirm = ArchiveVoiceAssistant.confirmMessage(
      _selectedField!,
      value,
      _isArabic,
    );
    _addBot(confirm);

    final fileListProvider = context.read<DocumentListProvider>();
    final screenProvider = context.read<ScreenContentProvider>();

    fileListProvider.requestAssistantFileSearch(
      field: _selectedField!,
      value: value,
    );
    screenProvider.setPage1(6);

    setState(() {
      _panelOpen = false;
      _step = _ChatStep.chooseField;
      _selectedField = null;
      _messages.clear();
    });
  }

  void _submitInput() {
    if (_step == _ChatStep.enterValue) {
      _submitValue();
    }
  }

  /// نفس عائلة لون شريط المنيو العلوي (`secondary`).
  static const LinearGradient _fabGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 16, 48, 74),
      secondary,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final isRtl = _isArabic;
    final hint = _step == _ChatStep.enterValue
        ? (_isArabic ? 'اكتب القيمة…' : 'Enter value…')
        : (_isArabic ? 'اختر من الأزرار أعلاه' : 'Pick an option above');

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_panelOpen) ...[
            _ChatPanel(
              isArabic: _isArabic,
              messages: _messages,
              scrollController: _scrollController,
              textInput: _textInput,
              inputEnabled: _step == _ChatStep.enterValue,
              inputHint: hint,
              onSubmit: _submitInput,
              onFieldSelected: _onFieldSelected,
              onNewSearch: _resetConversation,
              onClose: _closePanel,
            ),
            const SizedBox(height: 12),
          ],
          Material(
            elevation: 6,
            shadowColor: secondary.withOpacity(0.45),
            shape: const CircleBorder(),
            color: Colors.transparent,
            child: Ink(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: _fabGradient,
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  if (_panelOpen) {
                    _closePanel();
                  } else {
                    _openPanel();
                  }
                },
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Icon(
                    _panelOpen
                        ? Icons.close_rounded
                        : Icons.chat_bubble_outline,
                    color: textPrimary,
                    size: 26,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: bottomInset > 0 ? 0 : 8),
        ],
      ),
    );
  }
}

class _ChatPanel extends StatelessWidget {
  const _ChatPanel({
    required this.isArabic,
    required this.messages,
    required this.scrollController,
    required this.textInput,
    required this.inputEnabled,
    required this.inputHint,
    required this.onSubmit,
    required this.onFieldSelected,
    required this.onNewSearch,
    required this.onClose,
  });

  final bool isArabic;
  final List<_ChatMessage> messages;
  final ScrollController scrollController;
  final TextEditingController textInput;
  final bool inputEnabled;
  final String inputHint;
  final VoidCallback onSubmit;
  final void Function(AssistantSearchField field) onFieldSelected;
  final VoidCallback onNewSearch;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      color: theme.colorScheme.surface,
      child: Container(
        width: 340,
        height: 440,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    isArabic ? 'مساعد البحث' : 'Search assistant',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  tooltip: isArabic ? 'بحث جديد' : 'New search',
                  onPressed: onNewSearch,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onClose,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Bubble(message: msg, isArabic: isArabic),
                        if (msg.showFieldChoices)
                          _FieldChoiceChips(
                            isArabic: isArabic,
                            onSelected: onFieldSelected,
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textInput,
                    enabled: inputEnabled,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: inputHint,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: inputEnabled ? (_) => onSubmit() : null,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: secondary),
                  onPressed: inputEnabled ? onSubmit : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldChoiceChips extends StatelessWidget {
  const _FieldChoiceChips({
    required this.isArabic,
    required this.onSelected,
  });

  final bool isArabic;
  final void Function(AssistantSearchField field) onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 8, top: 4),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final info in kAssistantSearchFields)
            ActionChip(
              label: Text(
                info.label(isArabic),
                style: const TextStyle(fontSize: 12, color: secondary),
              ),
              backgroundColor: secondary.withOpacity(0.08),
              side: BorderSide(color: secondary.withOpacity(0.4)),
              onPressed: () => onSelected(info.field),
            ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.message,
    required this.isArabic,
  });

  final _ChatMessage message;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isUser
              ? secondary.withOpacity(0.14)
              : secondary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: secondary.withOpacity(0.22),
          ),
        ),
        child: Text(
          message.text,
          style: const TextStyle(fontSize: 14),
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        ),
      ),
    );
  }
}
