import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:scrobblium/page/settings/settings_page.dart';
import 'package:scrobblium/page/songs/songs_page.dart';
import 'package:scrobblium/page/stats_page.dart';
import 'package:scrobblium/service/song_data_service.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();

}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  static const List<Widget> _pages = [
    StatsPage(),
    SongsPage(),
    SettingsPage(),
  ];
  static const List<String> _titles = ["Stats", "Songs", "Settings"];

  @override
  void initState() {
    super.initState();
    SongDataService().fetchData();
  }
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
                  elevation: 3.2,
                  itemBuilder: (BuildContext context) {
                    List<PopupMenuEntry> list = [];
                    list.addAll(state.dropdownItems);
                    list.add(const PopupMenuItem(value: "about",child: Text("About"),));
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
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _selectedIndex = index);
          },
          children: _pages,
        ),
      bottomNavigationBar: Container(
        color: Theme.of(context).canvasColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 12.0),
          child: GNav(
            selectedIndex: _selectedIndex,
            backgroundColor: Theme.of(context).canvasColor,
            tabBackgroundColor: Theme.of(context).focusColor,
            padding: const EdgeInsets.all(12),
            gap: 8,
            tabs: const [
              GButton(
                icon: Icons.query_stats,
                text: 'Stats',
              ),
              GButton(
                icon: Icons.music_note,
                text: 'Songs',
              ),
              GButton(
                icon: Icons.settings,
                text: 'Settings',
              ),
            ],
            onTabChange: _onItemTapped,
            //currentIndex: _selectedIndex,
          ),
        ),
      )
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(index,
          duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
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