import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../utils/constants/sorted_by_constant.dart';
import '../../utils/func/responsive.dart';
import '../../widget/custom_drop_down.dart';
import '../../widget/text_field_widgets/custom_searchField.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  late AppLocalizations _locale;
  bool isDesktop = false;
  double width = 0;
  double height = 0;
  TextEditingController searchController = TextEditingController();
  int selectedStatus = -1;

  @override
  void didChangeDependencies() {
    _locale = AppLocalizations.of(context)!;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isDesktop = Responsive.isDesktop(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_locale.viewUser),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomSearchField(
                label: _locale.search,
                width: width * 0.45,
                padding: 8,
                controller: searchController,
                onChanged: (value) {},
              ),
              DropDown(
                key: UniqueKey(),
                onChanged: (value) {
                  selectedStatus = getStatusCode(_locale, value);
                },
                initialValue: selectedStatus == -1
                    ? null
                    : getStatusByCode(_locale, selectedStatus),
                bordeText: _locale.sortedBy,
                items: getStatusName(_locale),
                width: width * 0.2,
                height: height * 0.04,
              ),
            ],
          )
        ],
      ),
    );
  }
}
