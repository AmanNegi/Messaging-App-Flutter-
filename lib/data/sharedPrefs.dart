import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  SharedPreferences sharedPreferences;

//init in constructor
  initSharedPrefs() async {
    var value = await SharedPreferences.getInstance();
    this.sharedPreferences = value;
  }

  Future<bool> addItemToSharedPrefs(String key, dynamic value) {
    return sharedPreferences.setString(key, value);
  }

  addBoolToSharedPrefs(String key, dynamic value) {
    return sharedPreferences.setBool(key, value);
  }

  addIntToSharedPrefs(String key, int value) {
    return sharedPreferences.setInt(key, value);
  }

  bool checkIfExistsInSharedPrefs(String key) {
    return sharedPreferences.containsKey(key);
  }

  getValueFromSharedPrefs(String key) {
    return sharedPreferences.getString(key);
  }

  getBoolFromSharedPrefs(String key) {
    return sharedPreferences.getBool(key);
  }

  getIntFromSharedPrefs(String key) {
    return sharedPreferences.getInt(key);
  }
}

SharedPrefs sharedPrefs = SharedPrefs();
