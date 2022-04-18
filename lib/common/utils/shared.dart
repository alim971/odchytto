import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesWrapper {
  static final SharedPreferencesWrapper _singleton =
      SharedPreferencesWrapper._internal();

  factory SharedPreferencesWrapper() {
    return _singleton;
  }

  Future<SharedPreferences> _getPreference() async {
    _singleton.prefs ??= await SharedPreferences.getInstance();
    return _singleton.prefs!;
  }

  SharedPreferencesWrapper._internal();
  SharedPreferences? prefs;
  get(String key) async {
    if (prefs == null) {
      await _getPreference();
    }
    return prefs?.getString(key);
  }

  getList(String key) async {
    if (prefs == null) {
      await _getPreference();
    }
    return prefs?.getStringList(key);
  }

  getAll() async {
    if (prefs == null) {
      await _getPreference();
    }
    var keys = prefs?.getKeys();
    if (keys == null) {
      return <String>{};
    }
    keys.removeWhere((element) => element == 'locale' || element == 'currency');
    return keys;
  }

  put(String key, String value) async {
    if (prefs == null) {
      await _getPreference();
    }
    return await prefs?.setString(key, value);
  }

  putList(String key, List<String> value) async {
    if (prefs == null) {
      await _getPreference();
    }
    return await prefs?.setStringList(key, value);
  }

  delete(String key) async {
    if (prefs == null) {
      await _getPreference();
    }
    return await prefs?.remove(key);
  }
}
