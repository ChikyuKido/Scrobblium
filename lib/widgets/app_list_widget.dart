import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:installed_apps/app_category.dart';
import 'package:installed_apps/app_info.dart';

class AppListWidget extends StatefulWidget {
  final List<AppInfo> appList;
  final Function(AppInfo)? onAppSelected;

  const AppListWidget({super.key, required this.appList, this.onAppSelected});

  @override
  State<AppListWidget> createState() => _AppListWidgetState();
}

class _AppListWidgetState extends State<AppListWidget> {
  late List<AppInfo> _filteredAppList;

  @override
  void initState() {
    super.initState();
    _filteredAppList = widget.appList;
    _filterApps("");
  }

  void _filterApps(String query) {
    setState(() {
      _filteredAppList = widget.appList
          .where((app) => app.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      _filteredAppList
          .sort((a, b) => _getScoreForMusicApp(b) - _getScoreForMusicApp(a));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: _filterApps,
          decoration: const InputDecoration(
            labelText: 'Search',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 25),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: _filteredAppList.map((app) {
                return ListTile(
                  leading: SizedBox(
                    width: 40,
                    height: 40,
                    child: app.icon != null
                        ? Image.memory(app.icon ?? Uint8List(0))
                        : const Icon(Icons.apps),
                  ),
                  title: Text(app.name),
                  onTap: () {
                    if (widget.onAppSelected != null) {
                      widget.onAppSelected!(app);
                    }
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  int _getScoreForMusicApp(AppInfo appInfo) {
    int score = 0;
    if(appInfo.category.value == AppCategory.audio.value) score+=10;
    return score;
  }
}
