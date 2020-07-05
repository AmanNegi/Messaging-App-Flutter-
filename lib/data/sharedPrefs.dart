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

  bool checkIfExistsInSharedPrefs(String key) {
    return sharedPreferences.containsKey(key);
  }

  getValueFromSharedPrefs(String key) {
    return sharedPreferences.getString(key);
  }
}

SharedPrefs sharedPrefs = SharedPrefs();
