import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:provider/provider.dart';
import 'package:scrobblium/page/main_page.dart';
import 'package:scrobblium/service/app_theme_provider.dart';
import 'package:scrobblium/service/method_channel_service.dart';

void main() {
  initSettings().then((_) {
    runApp(const MyApp());
  });
}

Future<void> initSettings() async {
  await Settings.init(
    cacheProvider: SharePreferenceCache(),
  );
  MethodChannelService.init();
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
              ThemeData? data;
              if(state.darkMode) {
                data = FlexThemeData.dark(
                    useMaterial3: state.materialTheme,
                    //if darkcoloscheme is null just use the last selected scheme
                    colorScheme: state.materialTheme ? darkColorScheme ??
                        FlexColorScheme
                            .dark(scheme: state.colorScheme)
                            .colorScheme : null,
                    scheme: state.materialTheme ? null : state.colorScheme,
                    darkIsTrueBlack: state.trueDarkMode,
                    typography: Typography.material2021(
                        platform: defaultTargetPlatform));
                // somehow the canvas color is not true black when darkIsTrueBlack is set on.
                if (state.trueDarkMode) {
                  data = data.copyWith(
                      canvasColor: const Color(0x00000000),
                      appBarTheme: data.appBarTheme.copyWith(
                          backgroundColor: const Color(0x00000000)));
                }
              }else {
                data = FlexThemeData.light(
                    useMaterial3: state.materialTheme,
                    colorScheme: state.materialTheme ? lightColorScheme ??
                        FlexColorScheme
                            .light(scheme: state.colorScheme)
                            .colorScheme : null,
                    scheme: state.materialTheme ? null : state.colorScheme,
                    typography: Typography.material2021(
                        platform: defaultTargetPlatform));
              }

              return MaterialApp(
                title: 'Scrobblium',
                darkTheme: state.darkMode?data:null,
                theme: state.darkMode?null:data,
                themeMode: state.darkMode ?  ThemeMode.dark : ThemeMode.light,
                debugShowCheckedModeBanner: false,
                home: const MainPage(),
              );
            },
          ));
    });
  }
}
