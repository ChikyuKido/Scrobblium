import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrobblium/page/settings/settings_page.dart';
import 'package:scrobblium/page/songs_page.dart';
import 'package:scrobblium/page/stats_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();

}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  static const List<Widget> _pages = [
    StatsPage(),
    SongsPage(),
    SettingsPage(),
  ];
  static const List<String> _titles = ["Stats", "Songs", "Settings"];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_titles[_selectedIndex]),
        actions: [
          ChangeNotifierProvider(
            create: (context) => SettingsProvider(),
            builder: (context, child) {
              return Consumer<SettingsProvider>(builder: (context, state, child) {
                return PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (BuildContext context) {
                    List<PopupMenuEntry> list = [];
                    list.addAll(state.dropdownItems);
                    if(list.isNotEmpty) {
                      list.add(const PopupMenuDivider());
                    }
                    list.add(const PopupMenuItem(child: const Text("About"),value: "about",));
                    return list;
                  },
                  onSelected: (value) {
                    if(state.dropdownClickHandle != null) {
                      state.dropdownClickHandle?.call(value);
                    }
                  },
                );
              },).buildWithChild(context, child);
            },
          ),
        ],
      ),
      body: Center(
        child: _pages.elementAt(_selectedIndex), //New
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.query_stats),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'Songs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class SettingsProvider extends ChangeNotifier {
  List<PopupMenuItem<String>> _dropdownItems = [];
  List<PopupMenuItem<String>> get dropdownItems => _dropdownItems;

  PopupMenuItemSelected<String>? _dropdownClickHandle;
  PopupMenuItemSelected<String>? get dropdownClickHandle => _dropdownClickHandle;

  static final SettingsProvider _instance = SettingsProvider._internal();

  factory SettingsProvider() {
    return _instance;
  }
  SettingsProvider._internal();


  void updateSelectedPage(List<PopupMenuItem<String>> dropdownItems,PopupMenuItemSelected<String>? dropdownClickHandle) {
    _dropdownItems = dropdownItems;
    _dropdownClickHandle = dropdownClickHandle;
    notifyListeners();
  }
}