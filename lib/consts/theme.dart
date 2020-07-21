import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:messaging_app_new/data/strings.dart';

class AppTheme {
  static Color textColor = Colors.black;
  static Color iconColor = Colors.white;
  static Brightness brightness = Brightness.light;

  static Color accentColor = Colors.blue;
  static Color mainColor = Colors.blue;
  static Color primarySwatch = Colors.blue;
  static Color linkColor = Colors.blue;

  static Color isSeen = Colors.blue;

  // Message related color:
  static Color shadowColor = Colors.black38.withOpacity(0.1);
  static Color secondaryColor = Colors.grey;
  static Color notSeen = Colors.grey[400];
  static Color sendMessageTextColor = Colors.white;
  static Color receivedMessageTextColor = Colors.white;

  static Color seenTimeColor = Colors.white;
  static Color notSeenTimeColor = Colors.grey;

  static Color seenTextColor = Colors.white;
  static Color notSeenTextColor = Colors.black;

  static Color receivedTimeColor = Colors.grey;
  static Color secondaryTextColor = Colors.white;

  static Color buttonTextColor = Colors.white;
  static Color canvasColor = Colors.white;
  static String fontFamily = GoogleFonts.ubuntu().fontFamily;

  static Color shimmerBaseColor = Colors.grey[300];
  static Color shimmerEndingColor = Colors.grey[100];

  static changeColor(Color color) {
    accentColor = color;
    mainColor = color;
    primarySwatch = color;
    linkColor = color;
    isSeen = color;
  }

  static toDarkMode() {
    brightness = Brightness.dark;
    textColor = Colors.white;
    canvasColor = Colors.black;
    iconColor = Colors.white;
    sendMessageTextColor = Colors.white;
    receivedMessageTextColor = Colors.white;
    receivedTimeColor = Colors.white;
    notSeenTimeColor = Colors.white;

    shimmerBaseColor = Colors.grey[900];
    shimmerEndingColor = Colors.grey[700];
    notSeenTextColor = Colors.white;
  }

  static toLightMode() {
    brightness = Brightness.light;
    textColor = Colors.black;
    canvasColor = Colors.white;
    iconColor = Colors.black;
    sendMessageTextColor = Colors.black;
    receivedTimeColor = Colors.grey;
    shimmerBaseColor = Colors.grey[300];
    shimmerEndingColor = Colors.grey[100];
    receivedMessageTextColor = Colors.black;

    notSeenTimeColor = Colors.grey;
    notSeenTextColor = Colors.black;
  }

  static getThemeData() {
    return ThemeData(
        brightness: brightness,
        primaryColor: mainColor,
        accentColor: accentColor,
        primarySwatch: primarySwatch,
        fontFamily: fontFamily);
  }

  static changeFont(String font) {
    fontFamily = getFontFromString(font);
  }
}

getColorFromInt(int val) {
  if (val == 0) {
    return Colors.blue;
  } else if (val == 1) {
    return Colors.green;
  } else if (val == 2) {
    return Colors.deepOrange;
  } else {
    return Colors.deepPurple;
  }
}
