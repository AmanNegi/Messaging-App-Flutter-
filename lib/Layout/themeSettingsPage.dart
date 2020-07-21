import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:messaging_app_new/consts/theme.dart';
import 'package:messaging_app_new/data/sharedPrefs.dart';
import 'package:mdi/mdi.dart';

class ThemeSettingsPage extends StatefulWidget {
  @override
  _ThemeSettingsPageState createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  int currentColorIndex = 2;
  bool isDarkModeOpened = false;

  List<Map<String, dynamic>> fontList = [
    {'Default': GoogleFonts.ubuntu().fontFamily},
    {'Raleway': GoogleFonts.raleway().fontFamily},
    {'Exo': GoogleFonts.exo().fontFamily},
    {'QuickSand': GoogleFonts.quicksand().fontFamily},
    {
      'Comformtaa': GoogleFonts.comfortaa().fontFamily,
    }
  ];
  var dropDownValue = GoogleFonts.ubuntu().fontFamily;

  @override
  void initState() {
    if (sharedPrefs.checkIfExistsInSharedPrefs("darkMode")) {
      isDarkModeOpened = sharedPrefs.getBoolFromSharedPrefs('darkMode');
      print(" value of dark mode opened from sharedPrefs : $isDarkModeOpened");
    } else {
      _changeValueOfDarkModeInSharedPrefs(false);
    }
    if (sharedPrefs.checkIfExistsInSharedPrefs("fontFamily")) {
      dropDownValue = sharedPrefs.getValueFromSharedPrefs('fontFamily');
      print(" value of dropdown sharedPrefs : $dropDownValue");
    } else {
      dropDownValue = null;
      _changeValueOfFontFamilyInSharedPrefs(GoogleFonts.ubuntu().fontFamily);
    }
    if (sharedPrefs.checkIfExistsInSharedPrefs('mainColor')) {
      currentColorIndex = sharedPrefs.getIntFromSharedPrefs('mainColor');
      print(" value of currentColorIndex sharedPrefs : $currentColorIndex");
    } else {
      print(" else color statement");
      _changeValueOfMainColorInSharedPrefs(2);
    }
    super.initState();
  }

  _changeValueOfDarkModeInSharedPrefs(bool value) {
    sharedPrefs.addBoolToSharedPrefs('darkMode', value);
  }

  _changeValueOfFontFamilyInSharedPrefs(String value) {
    sharedPrefs.addItemToSharedPrefs('fontFamily', value);
  }

  _changeValueOfMainColorInSharedPrefs(int value) {
    sharedPrefs.addIntToSharedPrefs('mainColor', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Mdi.chevronLeft,
            color: AppTheme.iconColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'Theme Settings',
          style: TextStyle(color: AppTheme.iconColor),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildPrimaryColorSelector(),
          SwitchListTile(
            activeColor: AppTheme.mainColor,
            title: Text(
              "Dark Mode",
              style: TextStyle(color: AppTheme.textColor),
            ),
            value: isDarkModeOpened,
            onChanged: (value) {
              setState(() {
                isDarkModeOpened = value;
                _changeValueOfDarkModeInSharedPrefs(value);
                changeBrightness(value);
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField(
              hint: Text('Select a font'),
              value: dropDownValue != null ? dropDownValue : null,
              onChanged: (value) {
                print(" value changed to $value");
                setState(() {
                  dropDownValue = value;
                  changeFont(value);
                  _changeValueOfFontFamilyInSharedPrefs(value);
                });
              },
              items: fontList.map((e) {
                return DropdownMenuItem(
                  value: e.values.toList()[0],
                  child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        e.keys.toList()[0],
                        style: TextStyle(
                            fontFamily: e.values.toList()[0],
                            color: AppTheme.textColor),
                      )),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void changeColor(Color color) {
    AppTheme.changeColor(color);
    DynamicTheme.of(context).setThemeData(AppTheme.getThemeData());
  }

  void changeFont(String fontStyle) {
    AppTheme.changeFont(fontStyle);
    DynamicTheme.of(context).setThemeData(AppTheme.getThemeData());
  }

  void changeBrightness(value) {
    DynamicTheme.of(context)
        .setBrightness(value ? Brightness.dark : Brightness.light);
  }

  _buildPrimaryColorSelector() {
    return Container(
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 30.0, bottom: 10.0),
            child: Text(
              "Select primary color :-",
              style: TextStyle(fontSize: 18, color: AppTheme.textColor),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildColorTile(Colors.blue, 0, () {
                  setState(() {
                    currentColorIndex = 0;
                    changeColor(Colors.blue);
                    _changeValueOfMainColorInSharedPrefs(0);
                  });
                }),
                _buildColorTile(Colors.teal, 1, () {
                  setState(() {
                    currentColorIndex = 1;
                    changeColor(Colors.teal);
                    _changeValueOfMainColorInSharedPrefs(1);
                  });
                }),
                _buildColorTile(Colors.deepOrange, 2, () {
                  setState(() {
                    currentColorIndex = 2;
                    changeColor(Colors.deepOrange);
                    _changeValueOfMainColorInSharedPrefs(2);
                  });
                }),
                _buildColorTile(Colors.deepPurple, 3, () {
                  setState(() {
                    currentColorIndex = 3;
                    changeColor(Colors.deepPurple);
                    _changeValueOfMainColorInSharedPrefs(3);
                  });
                }),
              ],
            ),
          ),
          SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }

  _buildColorTile(Color color, int index, Function onPressed) {
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              //      color: index == currentColorIndex ? Colors.transparent : color,
              color: color,
              shape: BoxShape.circle),
          child: Padding(
            padding: EdgeInsets.all(3),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    index == currentColorIndex ? color : AppTheme.canvasColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                      color: index == currentColorIndex
                          ? color
                          : Colors.transparent,
                      shape: BoxShape.circle),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(30.0),
              onTap: onPressed,
            ),
          ),
        ),
      ],
    );
  }
}
