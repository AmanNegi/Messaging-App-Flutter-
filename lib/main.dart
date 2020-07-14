import 'dart:math';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:messaging_app_new/mainPage.dart';
import './auth/signUp.dart';
import 'data/sharedPrefs.dart';
import './consts/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await sharedPrefs.initSharedPrefs();
  AppTheme.fontFamily = sharedPrefs.getValueFromSharedPrefs('fontFamily');
  runApp(
    DynamicTheme(
      defaultBrightness: _getDarkMode(),
      data: (brightness) {
        AppTheme.changeFont(_getFontsFamily());
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
          theme: data,
          home: MyApp(),
        );
      },
    ),
  );
}

_getFontsFamily() {
  if (sharedPrefs.checkIfExistsInSharedPrefs('fontFamily')) {
    return (sharedPrefs.getValueFromSharedPrefs('fontFamily'));
  }
  return GoogleFonts.aBeeZee().fontFamily;
}

getMainColor() {
  if (sharedPrefs.checkIfExistsInSharedPrefs('mainColor')) {
    return getColorFromInt(sharedPrefs.getIntFromSharedPrefs('mainColor'));
  }
  return Colors.blue;
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
    if (sharedPrefs.checkIfExistsInSharedPrefs("uid")) {
      return MainPage();
    }
    return SignUpPage();
  }
}
