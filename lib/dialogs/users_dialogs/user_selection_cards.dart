import 'dart:async';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../models/db/user_models/user_model.dart';
import '../../models/dto/searchs_model/search_model.dart';
import '../../providers/user_provider.dart';
import '../../service/controller/users_controller/user_controller.dart';
import '../../widget/text_field_widgets/custom_searchField.dart';

// ── Design tokens ─────────────────────────────────────────────────
const Color _ucPrimary = Color(0xFF185FA5);
const Color _ucAccent = Color(0xFF0D9B8A);
const Color _ucBorder = Color(0xFFDDE3EE);
const Color _ucLabel = Color(0xFF8A94A6);
const Color _ucText = Color(0xFF1A2340);
const Color _ucBg = Color(0xFFF6F8FC);
const Color _ucCardBg = Colors.white;

class UserSelectionCards extends StatefulWidget {
  final String selectedCategoryId;
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

  final List<UserModel> _items = [];
  final Set<String> _codesSeen = {};
  int _page = 1;
  bool _isLast = false;
  bool _loading = false;
  String _query = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
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
    for (final u in all) {
      final code = u.txtCode ?? '';
      if (code.isEmpty) continue;
      if (_codesSeen.add(code)) _items.add(u);
    }

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
      return await _userController.getUsers(
        SearchModel(page: -1, searchField: query, status: -1),
      );
    } catch (_) {
      final all = <UserModel>[];
      var page = 1;
      while (true) {
        final batch = await _userController.getUsers(
          SearchModel(page: page, searchField: query, status: -1),
        );
        if (batch.isEmpty) break;
        all.addAll(batch);
        page += 1;
        if (page > 10000) break;
      }
      return all;
    }
  }

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      _query = v.trim();
      setState(() => _loading = true);
      _items.clear();
      _codesSeen.clear();
      final all = await _fetchAllUsers(query: _query);
      for (final u in all) {
        final code = u.txtCode ?? '';
        if (code.isEmpty) continue;
        if (_codesSeen.add(code)) _items.add(u);
      }
      _isLast = true;
      setState(() => _loading = false);
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Top bar: search + counter ──────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: CustomSearchField(
                  label: _local.search,
                  width: double.infinity,
                  padding: 0,
                  controller: _searchCtrl,
                  onChanged: _onSearchChanged,
                ),
              ),
              const SizedBox(width: 10),

              // ── Selected count badge ───────────────────────
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _ucPrimary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(99),
                  border:
                      Border.all(color: _ucPrimary.withOpacity(0.2), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people_outline_rounded,
                        size: 14, color: _ucPrimary),
                    const SizedBox(width: 5),
                    Text(
                      '${provider.selectedUsers.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _ucPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // ── List ──────────────────────────────────────────────
        Expanded(
          child: _loading && _items.isEmpty
              ? _buildSkeleton()
              : _items.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.only(bottom: 8),
                      itemCount: _items.length + (_loading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= _items.length) {
                          return const Padding(
                            padding: EdgeInsets.all(12),
                            child: Center(
                                child: CircularProgressIndicator(
                              strokeWidth: 2,
                            )),
                          );
                        }
                        return _buildUserCard(context, provider, index);
                      },
                    ),
        ),
      ],
    );
  }

  // ── User card ────────────────────────────────────────────────────
  Widget _buildUserCard(
      BuildContext context, UserProvider provider, int index) {
    final u = _items[index];
    final code = u.txtCode ?? '';
    final ref = u.txtReferenceUsername ?? '';
    final name = u.txtNamee ?? '';
    final selected = provider.selectedCodes.contains(code);

    return GestureDetector(
      onTap: () {
        if (selected && code.isNotEmpty) {
          provider.removeByCode(code);
        } else {
          provider.addUser(u);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        decoration: BoxDecoration(
          color: selected ? _ucPrimary.withOpacity(0.06) : _ucCardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _ucPrimary.withOpacity(0.4) : _ucBorder,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _ucPrimary.withOpacity(0.10),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  )
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // ── Avatar ──────────────────────────────────────
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: selected ? _ucPrimary : _ucPrimary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '#',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : _ucPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // ── Info ─────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Index badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: _ucBorder,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: _ucLabel,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            name.isEmpty ? _local.userName : name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: selected ? _ucPrimary : _ucText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${_local.userCode}: ',
                            style: const TextStyle(
                              fontSize: 11,
                              color: _ucPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: code.isEmpty ? '- ' : '$code ',
                            style: const TextStyle(
                              fontSize: 11,
                              color: _ucLabel,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const TextSpan(
                            text: '· ',
                            style: TextStyle(
                              fontSize: 11,
                              color: _ucPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: '${_local.refNumber}: ',
                            style: const TextStyle(
                              fontSize: 11,
                              color: _ucPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: ref.isEmpty ? '-' : ref,
                            style: const TextStyle(
                              fontSize: 11,
                              color: _ucLabel,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // ── Checkbox ─────────────────────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: selected ? _ucPrimary : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: selected ? _ucPrimary : _ucBorder,
                    width: 1.5,
                  ),
                ),
                child: selected
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 14)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Small info chip ──────────────────────────────────────────────
  Widget _chip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: _ucLabel),
        const SizedBox(width: 3),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            color: _ucLabel,
          ),
        ),
      ],
    );
  }

  // ── Skeleton loader ──────────────────────────────────────────────
  Widget _buildSkeleton() {
    return ListView.builder(
      itemCount: 6,
      padding: const EdgeInsets.only(bottom: 8),
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          height: 64,
          decoration: BoxDecoration(
            color: _ucBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _ucBorder, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _ucBorder,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 11,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _ucBorder,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 9,
                        width: 120,
                        decoration: BoxDecoration(
                          color: _ucBorder.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Empty state ──────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _ucPrimary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.people_outline_rounded,
                size: 28, color: _ucPrimary),
          ),
          const SizedBox(height: 12),
          Text(
            _local.search,
            style: const TextStyle(
              fontSize: 13,
              color: _ucLabel,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
