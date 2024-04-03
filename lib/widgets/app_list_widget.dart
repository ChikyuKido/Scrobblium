
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';

class AppListWidget extends StatefulWidget {
  final List<AppInfo> appList;
  final Function(AppInfo)? onAppSelected;

  AppListWidget({required this.appList, this.onAppSelected});

  @override
  _AppListWidgetState createState() => _AppListWidgetState();
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
          .where((app) =>
          app.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      _filteredAppList.sort((a, b) => _getScoreForMusicApp(b)-_getScoreForMusicApp(a));
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
          child: ListView.builder(
            itemCount: _filteredAppList.length,
            itemBuilder: (context, index) {
              final app = _filteredAppList[index];
              return ListTile(
                leading: SizedBox(
                  width: 40,
                  height: 40,
                  child: app.icon != null ? Image.memory(app.icon??Uint8List(0)) : const Icon(Icons.apps),
                ),
                title: Text(app.name),
                onTap: () {
                  if (widget.onAppSelected != null) {
                    widget.onAppSelected!(app);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
  
  int _getScoreForMusicApp(AppInfo appInfo) {
    int score = 0;
    if(appInfo.permissions.contains("android.permission.READ_MEDIA_AUDIO")) score++;
    if(appInfo.permissions.contains("android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK")) score++;
    if(appInfo.permissions.contains("android.permission.FOREGROUND_SERVICE")) score++;
    if(appInfo.permissions.contains("android.permission.WAKE_LOCK")) score++;
    return score;
  }
}
