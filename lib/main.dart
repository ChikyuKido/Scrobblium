import 'dart:async';
import 'dart:io';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scrobblium/page/main_page.dart';
import 'package:scrobblium/service/app_theme_provider.dart';
import 'package:provider/provider.dart';

void main() {
  initSettings().then((_) {
    runApp(const MyApp());
  });
}

Future<void> initSettings() async {
  await Settings.init(
    cacheProvider: SharePreferenceCache(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => AppThemeProvider(),
        child: Consumer<AppThemeProvider>(
          builder: (context, state, child) {
            return MaterialApp(
              title: 'Scrobblium',
              theme: FlexThemeData.light(scheme: FlexScheme.hippieBlue),
              darkTheme: FlexThemeData.dark(useMaterial3: true,scheme: FlexScheme.wasabi, darkIsTrueBlack: state.trueDarkMode),
              themeMode: ThemeMode.dark,
              debugShowCheckedModeBanner: false,
              home: const MainPage(),
            );
          },
        ));
  }
}

