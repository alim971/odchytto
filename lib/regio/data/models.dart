// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Middleware that manages interactions between ui and api
import 'dart:io';
import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:watcher/common/data/localization.dart';
import 'package:watcher/common/utils/shared.dart';
import 'package:watcher/common/utils/utils.dart';
import 'package:watcher/regio/data/api.dart' as api;
import 'package:watcher/regio/data/data.dart';
import 'package:watcher/regio/utils/utils.dart';

import '../../common/data/data.dart';

/// Journey data
class JourneyNotifier with ChangeNotifier {
  final SharedPreferencesWrapper _prefs = SharedPreferencesWrapper();

  static init() async {
    _language = await getLocale();
    _currency = await getCurrency();

    if (_allLocations == null) {
      _allLocations = await _getAllLocationsInit();
    }
  }

  static Future<List<Location>> _getAllLocationsInit() async {
    return await api.getLocations("", _language, _currency);
  }

  static Future<String> getLocale() async {
    final saved = await SharedPreferencesWrapper().get('locale');
    if (saved != null) {
      return PrefsNotifier.supportedLanguages[int.parse(saved)]!.languageCode;
    }
    return Platform.localeName.split('_')[0];
  }

  static Future<String> getCurrency() async {
    final saved = await SharedPreferencesWrapper().get('currency');
    if (saved != null) {
      return PrefsNotifier.supportedCurrency[int.parse(saved)]!.name;
    }
    return PrefsNotifier.supportedCurrency[0]!.name;
  }

  bool isLoading = false;
  bool isError = false;
  String error = '';
  static String _language = 'cs'; //TODO change to load from cache

  String get language => _language;

  set language(String language) {
    _language = language;
    _getAllLocations();
  }

  static String _currency = 'CZK';

  String get currency => _currency;

  set currency(String currency) {
    _currency = currency;
    _getAllLocations();
  }

  _deleteOld() async {
    var set = await _prefs.getAll();
    for (var route in set) {
      var entityId = await _prefs.get(route);
      if ((await api.getEntity(entityId)) == null) {
        await _prefs.delete(route);
      }
    }
  }

  Future<WatchedEntity?> getWatched(routeId) async {
    if (await isWatched(routeId)) {
      var entityId = await _prefs.get(routeId);
      var entity = api.getEntity(entityId);
      return entity;
    }
    return null;
  }

  Future<bool> isWatched(String routeId) async {
    var set = await _prefs.getAll();
    return set.contains(routeId);
  }

  Future<bool> isSeatOrTypeWatched(
      String routeId, String type, String seatClass) async {
    var entity = await getWatched(routeId);
    if (entity == null) {
      return false;
    }
    return entity.type.contains(type) &&
        ((entity.type == "delays") ||
            (entity.seatClasses.isEmpty && seatClass == "") ||
            (entity.seatClasses.contains(seatClass) && seatClass != ""));
  }

  Future<bool> deleteWatchedEntity(String entityId, String routeId) async {
    if (await api.deleteEntity(entityId)) {
      while (!await _prefs.delete(routeId)) {}
      return true;
    }
    return false;
  }

  Future<bool> deleteWatched(String routeId) async {
    if (await isWatched(routeId)) {
      var entityId = await _prefs.get(routeId);
      return deleteWatchedEntity(entityId, routeId);
    }
    return false;
  }

  bool isReadyToFetch() {
    return _departure != null && _arrival != null && _date != null;
  }

  void refresh({bool shouldDelete = false, forceRefresh = false}) {
    _getSeats();
    if (shouldDelete) {
      _deleteOld();
    }
    _fetchRoutes(forceRefresh: forceRefresh);
  }

  void postWhole(WatchedEntity entity) async {
    WatchedEntity result = await api.postEntity(entity);
    await _prefs.put(result.routeId, result.id!);
  }

  void post(
      String routeId,
      String fromStationId,
      String toStationId,
      String seatClass,
      DateTime arrivalTime,
      DateTime departureTime,
      List<String> type) async {
    String? userId = await FirebaseMessaging.instance.getToken();
    if (userId == null) {
      return;
    }
    final WatchedEntity entity = WatchedEntity(
        userId: userId,
        routeId: routeId,
        fromStationId: fromStationId,
        toStationId: toStationId,
        tickets: _tariffs.length,
        tariffs: _tariffs.map<String>((e) => e.key).toList(),
        seatClasses: seatClass == '' ? [] : [seatClass],
        arrivalTime: arrivalTime,
        departureTime: departureTime,
        type: type.reduce((value, element) => value + element),
        url: getRegioShopUrl(routeId, fromStationId, toStationId,
            _tariffs.map<String>((e) => e.key)));
    postWhole(entity);
  }

  // Cache flag
  var _useCache = false;
  bool get useCache => _useCache;
  set useCache(bool val) {
    _useCache = val;
    notifyListeners();
  }

  List<Tariff> _tariffs = [const Tariff(key: "REGULAR", description: "init")];
  List<Tariff> get tariffs => _tariffs;
  set tariffs(List<Tariff> tariffs) {
    _tariffs = tariffs;
    _fetchRoutes();
    notifyListeners();
  }

  bool initialized = false;

  _getSeats() async {
    var seatsList = await _loadSeats();
    update(SeatClass element) {
      if (element.key == "NO") {
        element.title =
            AppLocalizations(Locale(_language)).noClass; //TODO add translation
      } else {
        element.title =
            AppLocalizations(Locale(language)).local + element.title;
      }
      return element;
    }

    // seatsList!.removeWhere((element) =>
    // element.key == "TRAIN_1ST_CLASS" ||
    // element.key == "TRAIN_2ND_CLASS" ||
    // element.key == "TRAIN_STANDARD_PLUS" ||
    // element.key == "NO"); //||
    // element.key == "TRAIN_COUCHETTE_BUSINESS_4");
    _seats = {
      for (var v in seatsList!)
        v.key: v.key == "TRAIN_1ST_CLASS" ||
                v.key == "TRAIN_2ND_CLASS" ||
                v.key == "TRAIN_STANDARD_PLUS" ||
                v.key == "TRAIN_COUCHETTE_BUSINESS_4" ||
                v.key == "NO"
            ? update(v)
            : v
    };
  }

  Future<List<Tariff>?> getTariffs() async {
    var result = await api.getTariffs(language, currency);
    if (!initialized) {
      initialized = true;
      _deleteOld();
      _getAllLocations();
      _getSeats();
      _tariffs = [result.firstWhere((element) => element.key == 'REGULAR')];
    }
    return result;
  }

  Map<String, SeatClass>? _seats;

  Map<String, SeatClass>? get seats => _seats;

  set seats(Map<String, SeatClass>? seats) {
    _seats = seats;
  }

  Future<Connection?> getConnection(RouteTransport route,
      {onlyData = false}) async {
    if (route.freeSeats == 0 ||
        (!onlyData && route.freeSeats < _tariffs.length)) {
      return null;
    }
    return await _loadConnection(
        onlyData
            ? [_tariffs[0].key]
            : _tariffs.map<String>((e) => e.key).toList(),
        route.id,
        route.arrivalStation,
        route.departureStation,
        language,
        currency);
  }

  DateTime _date = DateTime.now();

  DateTime get date => _date;

  set date(DateTime date) {
    _date = date;
    _fetchRoutes();
    notifyListeners();
  }

  // Depature data
  Location? _departure;
  Location? get departure => _departure;
  set departure(Location? place) {
    final tmp = _departure;
    _departure = place;
    if (tmp == null || tmp.id != _departure?.id) {
      _fetchRoutes();
    }
    notifyListeners();
  }

  // Arrival data
  Location? _arrival;
  Location? get arrival => _arrival;
  set arrival(Location? place) {
    final tmp = _arrival;
    _arrival = place;
    if (tmp == null || tmp.id != _arrival?.id) {
      _fetchRoutes();
    }
    notifyListeners();
  }

  List<RouteTransport>? _routes;

  List<RouteTransport>? get routes => _routes;

  set routes(List<RouteTransport>? routes) {
    _routes = routes;
  }

  Future<RouteTransport?> getRoute(
      String arrivalType,
      String arrivalId,
      String departureType,
      String departureId,
      String routeId,
      String date) async {
    final tmp = await api.getRoutes(
        _tariffs.map<String>((e) => e.key).toList(),
        arrivalType,
        arrivalId,
        departureType,
        departureId,
        date,
        language,
        currency);
    for (var route in tmp) {
      if (route.id == routeId) {
        return route;
      }
    }
    return null;
  }

  void _fetchRoutes({bool forceRefresh = false}) async {
    // var seatsList = await _loadSeats();
    if (isReadyToFetch()) {
      isError = false;
      error = '';
      isLoading = true;
      notifyListeners();
      try {
        _routes = await api.getRoutes(
            _tariffs.map<String>((e) => e.key).toList(),
            _arrival!.type,
            _arrival!.id,
            _departure!.type,
            _departure!.id,
            prettyDate(_date),
            language,
            currency,
            forceRefresh: forceRefresh);
        isLoading = false;
        notifyListeners();
      } catch (e) {
        isLoading = false;
        error = e.toString();
        isError = true;
        notifyListeners();
      }
    }
  }

  static List<Location>? _allLocations;

  List<Location>? get allLocations => _allLocations;

  set allLocations(List<Location>? allLocations) {
    _allLocations = allLocations;
  }

  void _getAllLocations() async {
    _allLocations = await api.getLocations("", language, currency);
    if (arrival != null) {
      arrival =
          _allLocations!.firstWhere((location) => location.id == arrival!.id);
    }
    if (departure != null) {
      departure =
          _allLocations!.firstWhere((location) => location.id == departure!.id);
    }
  }

  List<Location>? _locationSearchResults;
  List<Location>? get locationSearchResults => _locationSearchResults;
  Future<List<Location>?> getLocations(String query) async {
    if (query == '') {
      return null;
    }
    _locationSearchResults = await api.getLocations(query, language, currency);
    return _locationSearchResults;
  }

  Future<List<Location>?> locationSearchPlaces(String query) async {
    if (query == '') {
      return null;
    }
    _locationSearchResults = await api.getLocations(query, language, currency);
    return _locationSearchResults;
  }

  Future<Connection?> _loadConnection(
      List<String> list,
      String route,
      String arrivalStation,
      String departureStation,
      String language,
      String currency) async {
    return await api.getConnection(
        list, route, arrivalStation, departureStation, language, currency);
  }

  Future<List<SeatClass>?> _loadSeats() async {
    return api.getSeats(language, currency);
  }

  void swap() {
    final tmp = _departure;
    _departure = _arrival;
    _arrival = tmp;
    _fetchRoutes();
    notifyListeners();
  }

  JourneyNotifier() {
    init();
  }
}

/// Preferences
class PrefsNotifier with ChangeNotifier {
  Future<bool> init() async {
    _localeSelector = await getLocale();
    _currencySelector = await getCurrency();
    await getVersion();
    return true;
  }

  getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    appName = packageInfo.appName;
    packageName = packageInfo.packageName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
  }

  Future<int> getLocale() async {
    final saved = await SharedPreferencesWrapper().get('locale');
    if (saved != null) {
      return int.parse(saved);
    }
    switch (Platform.localeName.split('_')[0]) {
      case 'cs':
        return 0;
      case 'sk':
        return 1;
      case 'en':
        return 2;
      default:
        return 0;
    }
  }

  Future<int> getCurrency() async {
    final saved = await SharedPreferencesWrapper().get('currency');
    if (saved != null) {
      return int.parse(saved);
    }
    return 0;
  }

  // Locale
  static const Map<int, Locale> supportedLanguages = {
    0: Locale('cs'),
    1: Locale('sk'),
    2: Locale('en'),
  };

  static const Map<int, Currency> supportedCurrency = {
    0: Currency(code: 'KČ', name: 'CZK'),
    1: Currency(code: '€', name: 'EUR'),
  };

  String appName = "";
  String packageName = "";
  String version = "";
  String buildNumber = "";

  // The selector value, which maps to supportedLanguages
  int _localeSelector = 0;
  int get localeSelector => _localeSelector;
  setLocaleSelector(int val, JourneyNotifier notifier) {
    assert(val >= 0 && val <= 2);
    _localeSelector = val;
    notifier.language = locale.languageCode;

    notifier.refresh();
    notifyListeners();
    SharedPreferencesWrapper().put('locale', val.toString());
  }

  void refresh() {
    notifyListeners();
  }

  Locale get locale => supportedLanguages[_localeSelector]!;

  // The selector value, which maps to supportedLanguages
  int _currencySelector = 0;
  int get currencySelector => _currencySelector;
  void setCurrency(int val, JourneyNotifier notifier) {
    assert(val >= 0 && val <= 1);
    _currencySelector = val;
    notifier.currency = supportedCurrency[val]!.name;
    notifier.refresh();
    notifyListeners();
    SharedPreferencesWrapper().put('currency', val.toString());
  }

  Currency get currency => supportedCurrency[_currencySelector]!;

  PrefsNotifier() {
    init();
  }
}

/// App state
class AppStateNotifier with ChangeNotifier {
  // Splash screen
  bool _showSplash = true;
  bool get showSplash => _showSplash;

  void hideSplash() {
    _showSplash = false;
    notifyListeners();
  }

  void resetSplash() {
    _showSplash = true;
    notifyListeners();
  }
}
