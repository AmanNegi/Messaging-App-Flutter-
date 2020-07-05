import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final Color textColor = Colors.black;
final Color iconColor = Colors.white;
final Color accentColor = Colors.lightBlueAccent;
final Color mainColor = Colors.blue;
final Color primarySwatch = Colors.blue;
final Color linkColor = Colors.blueAccent;
final Color secondaryColor = Colors.grey;
final Color isSeen = mainColor;
final Color notSeen = Colors.grey[400];
final Color sendMessageTextColor = Colors.white;
final Color receivedMessageTextColor = Colors.black;
final Color timeColor = Colors.white70;
final Color buttonTextColor = Colors.white;
final Color secondaryTextColor = Colors.white;
final Color canvasColor = Colors.white;
final String fontFamily = GoogleFonts.aBeeZee().fontFamily;

class AppTheme {
  static getThemeData() {
    return ThemeData(
        canvasColor: canvasColor,
        primaryColor: mainColor,
        accentColor: accentColor,
        primarySwatch: primarySwatch,
        fontFamily: fontFamily);
  }
}
