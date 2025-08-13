import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../models/db/user_models/user_model.dart';
import '../../models/dto/searchs_model/search_model.dart';
import '../../providers/user_provider.dart';
import '../../service/controller/users_controller/user_controller.dart';

class UserSelectionCards extends StatefulWidget {
  final String selectedCategoryId; // يتغير عند اختيار تصنيف جديد
  final double? listHeight;
  final double? listWidth;

  const UserSelectionCards({
    super.key,
    required this.selectedCategoryId,
    this.listHeight,
    this.listWidth,
  });

  @override
  State<UserSelectionCards> createState() => _UserSelectionCardsState();
}

class _UserSelectionCardsState extends State<UserSelectionCards> {
  late AppLocalizations _local;
  final _userController = UserController();

  final _scroll = ScrollController();
  final _searchCtrl = TextEditingController();
  bool _didInitialFetch = false;

  // data + paging
  final List<UserModel> _items = [];
  final Set<String> _codesSeen = {}; // prevents duplicates across pages
  int _page = 1;
  bool _isLast = false;
  bool _loading = false;
  String _query = '';

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);

    // if the parent already passed a category id, load immediately
    if (widget.selectedCategoryId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _resetAndLoad());
      _didInitialFetch = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _local = AppLocalizations.of(context)!;

    if (!_didInitialFetch && widget.selectedCategoryId.isNotEmpty) {
      _didInitialFetch = true;
      _resetAndLoad();
    }
  }

  @override
  void didUpdateWidget(covariant UserSelectionCards oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCategoryId != widget.selectedCategoryId) {
      _resetAndLoad();
    }
  }

  void _resetAndLoad() async {
    _items.clear();
    _codesSeen.clear();
    _page = 1;
    _isLast = false;
    _query = _searchCtrl.text.trim();
    if (_scroll.hasClients) _scroll.jumpTo(0);
    setState(() => _loading = true);

    final all = await _fetchAllUsers(query: _query);

    // أمنع التكرار
    for (final u in all) {
      final code = u.txtCode ?? '';
      if (code.isEmpty) continue;
      if (_codesSeen.add(code)) _items.add(u);
    }

    // بما إننا جبنا الكل بالفعل:
    _isLast = true;
    _loading = false;
    setState(() {});
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      if (!_loading && !_isLast) _fetchAllUsers(query: '');
    }
  }

  Future<List<UserModel>> _fetchAllUsers({required String query}) async {
    try {
      // ✳️ لو السيرفر يدعم page = -1 (كما في كودك القديم)
      final all = await _userController.getUsers(
        SearchModel(page: -1, searchField: query, status: -1),
      );
      return all;
    } catch (_) {
      // 🔁 fallback: نجمع كل الصفحات
      final all = <UserModel>[];
      var page = 1;
      while (true) {
        final batch = await _userController.getUsers(
          SearchModel(page: page, searchField: query, status: -1),
        );
        if (batch.isEmpty) break;
        all.addAll(batch);
        page += 1;
        if (page > 10000) break; // أمان
      }
      return all;
    }
  }

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _query = v.trim();
      _items.clear();
      _codesSeen.clear();
      _page = 1;
      _isLast = false;
      setState(() {});
      _fetchAllUsers(query: '');
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final selectedCodes = provider.selectedCodes.toSet();

    // Pin selected first (visual)
    final itemsSorted = [..._items]..sort((a, b) {
        final aSel = selectedCodes.contains(a.txtCode ?? '');
        final bSel = selectedCodes.contains(b.txtCode ?? '');
        if (aSel == bSel) return 0;
        return aSel ? -1 : 1;
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar + selected count
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  labelText: _local.search,
                  isDense: true,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchCtrl.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchCtrl.clear();
                            _onSearchChanged('');
                          },
                        ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${_local.users}: ${provider.selectedUsers.length}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Cards list
        Expanded(
          child: Container(
            width: widget.listWidth,
            height: widget.listHeight,
            child: RefreshIndicator(
              onRefresh: () async {
                _resetAndLoad();
              },
              child: ListView.builder(
                  controller: _scroll,
                  itemCount: itemsSorted.length + (_loading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= itemsSorted.length) {
                      // bottom loader
                      return const Padding(
                        padding: EdgeInsets.all(12),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final u = itemsSorted[index];
                    final code = u.txtCode ?? '';
                    final ref = u.txtReferenceUsername ?? '';
                    final name = u.txtNamee ?? '';
                    final selected = provider.selectedCodes.contains(code);

                    // Alternate colors: even = white, odd = light grey
                    final backgroundColor =
                        index.isEven ? Colors.white : Colors.grey[200];

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      elevation: selected ? 4 : 1,
                      color: backgroundColor,
                      child: ListTile(
                        onTap: () => provider.toggleUser(u),

                        // Show index + name
                        title: Text(
                          '${index + 1}. ${name.isEmpty ? _local.userName : name}',
                        ),
                        subtitle: Text(
                          '${_local.userCode}: ${code.isEmpty ? "-" : code} · ${_local.refNumber}: ${ref.isEmpty ? "-" : ref}',
                        ),
                        trailing: Checkbox(
                          value: selected,
                          onChanged: (val) {
                            if (val == true) {
                              provider.addUser(u);
                            } else {
                              if (code.isNotEmpty) provider.removeByCode(code);
                            }
                          },
                        ),
                      ),
                    );
                  }),
            ),
          ),
        ),

        if (!_loading && itemsSorted.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                _local.search.isEmpty ? _local.userName : _local.search,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
      ],
    );
  }
}
