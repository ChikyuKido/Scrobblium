import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
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

  @override
  void initState() {
    super.initState();
    SongDataService().fetchData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                icon: Icons.insert_chart,
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
