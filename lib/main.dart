import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:messaging_app_new/mainPage.dart';
import './auth/signUp.dart';
import 'data/sharedPrefs.dart';
import './consts/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await sharedPrefs.initSharedPrefs();
  runApp(
    MaterialApp(
      theme: AppTheme.getThemeData(),
      home: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    if (sharedPrefs.checkIfExistsInSharedPrefs("uid")) {
      return MainPage();
    }
    return SignUpPage();
  }
}
