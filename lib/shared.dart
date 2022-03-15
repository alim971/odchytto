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
  // SharedPreferencesWrapper({required this.prefs});
  SharedPreferences? prefs;
  get(String routeId) async {
    // final prefs = await SharedPreferences.getInstance();
    await _getPreference();
    return prefs?.getString(routeId);
  }

  getAll() async {
    // final prefs = await SharedPreferences.getInstance();
    await _getPreference();
    return prefs?.getKeys();
  }

  put(String routeId, String watchedId) async {
    // final prefs = await SharedPreferences.getInstance();

    await _getPreference();
    return await prefs?.setString(routeId, watchedId);
    // List<String>? items = prefs.getStringList('routes');
    // items ??= [];
    // items.add(routeId);
    // await prefs.setStringList('routes' ,items);
  }

  delete(String routeId) async {
    await _getPreference();
    return await prefs?.remove(routeId);
  }
}
