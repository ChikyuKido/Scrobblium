import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:provider/provider.dart';
import 'package:scrobblium/page/main_page.dart';
import 'package:scrobblium/service/app_theme_provider.dart';

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
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return ChangeNotifierProvider(
          create: (context) => AppThemeProvider(),
          child: Consumer<AppThemeProvider>(
            builder: (context, state, child) {
              ThemeData data = FlexThemeData.dark(
                useMaterial3: state.materialTheme,
                //if darkcoloscheme is null just use the last selected scheme
                colorScheme: state.materialTheme ? darkColorScheme ?? FlexColorScheme.dark(scheme: state.colorScheme).colorScheme : null,
                scheme: state.materialTheme ? null : state.colorScheme,
                darkIsTrueBlack: state.trueDarkMode,
                typography: Typography.material2021(
                    platform: defaultTargetPlatform),);
              // somehow the canvas color is not true black when darkIsTrueBlack is set on.
              data = data.copyWith(
                  canvasColor: state.trueDarkMode
                      ? const Color(0x00000000)
                      : data.canvasColor);
              return MaterialApp(
                title: 'Scrobblium',
                darkTheme: data,
                themeMode: ThemeMode.dark,
                debugShowCheckedModeBanner: false,
                home: const MainPage(),
              );
            },
          ));
    });
  }
}
