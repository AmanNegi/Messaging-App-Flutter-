import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:messaging_app_new/mainPage.dart';
import './auth/signUp.dart';
import 'data/sharedPrefs.dart';
import './consts/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = true;
  await sharedPrefs.initSharedPrefs();
  runApp(
    DynamicTheme(
      defaultBrightness: _getDarkMode(),
      data: (brightness) {
        AppTheme.changeFont(getFontsFamily());
        AppTheme.changeColor(getMainColor());
        if (brightness == Brightness.dark) {
          AppTheme.toDarkMode();
          return AppTheme.getThemeData();
        } else {
          AppTheme.toLightMode();
          return AppTheme.getThemeData();
        }
      },
      themedWidgetBuilder: (context, data) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: data,
          home: MyApp(),
        );
      },
    ),
  );
}

String getFontsFamily() {
  if (sharedPrefs.checkIfExistsInSharedPrefs('fontFamily')) {
    print("got value from sharedPrefs : " +
        sharedPrefs.getValueFromSharedPrefs('fontFamily'));

    return sharedPrefs.getValueFromSharedPrefs('fontFamily');
  }
  return GoogleFonts.ubuntu().fontFamily;
}

getMainColor() {
  if (sharedPrefs.checkIfExistsInSharedPrefs('mainColor')) {
    return getColorFromInt(sharedPrefs.getIntFromSharedPrefs('mainColor'));
  }
  return Colors.deepOrange;
}

_getDarkMode() {
  if (sharedPrefs.checkIfExistsInSharedPrefs('darkMode')) {
    if (sharedPrefs.getBoolFromSharedPrefs('darkMode')) {
      return Brightness.dark;
    }
    return Brightness.light;
  }
  return Brightness.light;
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    if (!sharedPrefs.checkIfExistsInSharedPrefs("isLoggedIn"))
      return SignUpPage();
    else {
      if (sharedPrefs.getBoolFromSharedPrefs('isLoggedIn'))
        return MainPage();
      else
        return SignUpPage();
    }
  }
}
