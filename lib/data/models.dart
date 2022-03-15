// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Middleware that manages interactions between ui and api
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:watcher/data/api.dart' as api;
import 'package:watcher/data/cache.dart' as cache;
import 'package:watcher/data/data.dart';

import '../shared.dart';
import '../utils.dart';

/// Journey data
class JourneyNotifier with ChangeNotifier {
  final SharedPreferencesWrapper _prefs = SharedPreferencesWrapper();

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

  Future<bool> deleteWatched(String routeId) async {
    if (await isWatched(routeId)) {
      var entityId = await _prefs.get(routeId);
      if (await api.deleteEntity(entityId)) {
        while (!await _prefs.delete(routeId)) {}
        return true;
      }
    }
    return false;
  }

  bool isReadyToFetch() {
    return _departure != null && _arrival != null && _date != null;
  }

  void refresh() {
    _deleteOld();
    _fetchRoutes();
  }

  void postWhole(WatchedEntity entity) async {
    WatchedEntity result = await api.postEntity(entity);
    await _prefs.put(result.routeId, result.id!);
  }

  void post(String routeId, String fromStationId, String toStationId,
      String seatClass, DateTime arrivalTime, List<String> type) async {
    final WatchedEntity entity = WatchedEntity(
        userId: "userId",
        routeId: routeId,
        fromStationId: fromStationId,
        toStationId: toStationId,
        tickets: _tariffs.length,
        tariffs: _tariffs.map<String>((e) => e.key).toList(),
        seatClasses: [seatClass],
        arrivalTime: arrivalTime,
        type: type.reduce((value, element) => value + element));
    postWhole(entity);
  }

  // Cache flag
  var _useCache = false;
  bool get useCache => _useCache;
  set useCache(bool val) {
    _useCache = val;
    notifyListeners();
  }

  late List<Tariff> _tariffs;
  List<Tariff> get tariffs => _tariffs;
  set tariffs(List<Tariff> tariffs) {
    _tariffs = tariffs;
    _fetchRoutes();
    notifyListeners();
  }

  bool initialized = false;

  Future<List<Tariff>?> getTariffs() async {
    var result = await _loadTariffs();
    if (!initialized) {
      initialized = true;
      _deleteOld();
      _getAllLocations();
      var seatsList = await _loadSeats();
      seatsList!.removeWhere((element) =>
          element.key == "TRAIN_1ST_CLASS" ||
          element.key == "TRAIN_2ND_CLASS" ||
          element.key == "TRAIN_STANDARD_PLUS" ||
          element.key == "NO" ||
          element.key == "TRAIN_COUCHETTE_BUSINESS_4");
      _seats = {for (var v in seatsList) v.key: v};
      _tariffs = [result.firstWhere((element) => element.key == 'REGULAR')];
    }
    return result;
  }

  Map<String, SeatClass>? _seats;

  Map<String, SeatClass>? get seats => _seats;

  set seats(Map<String, SeatClass>? seats) {
    _seats = seats;
  }

  Future<Connection?> getConnection(Route route, {onlyData = true}) async {
    if (route.freeSeats == 0 ||
        (onlyData && route.freeSeats < _tariffs.length)) {
      return null;
    }
    return await _loadConnection(
      onlyData
          ? [_tariffs[0].key]
          : _tariffs.map<String>((e) => e.key).toList(),
      route.id,
      route.arrivalStation,
      route.departureStation,
    );
  }

  DateTime? _date;

  DateTime? get date => _date;

  set date(DateTime? date) {
    _date = date;
    _fetchRoutes();
    notifyListeners();
  }

  // Depature data
  LocationS? _departure;
  LocationS? get departure => _departure;
  set departure(LocationS? place) {
    _departure = place;
    _fetchRoutes();
    notifyListeners();
  }

  // Arrival data
  LocationS? _arrival;
  LocationS? get arrival => _arrival;
  set arrival(LocationS? place) {
    _arrival = place;
    _fetchRoutes();
    notifyListeners();
  }

  List<Route>? _routes;

  List<Route>? get routes => _routes;

  set routes(List<Route>? routes) {
    _routes = routes;
  }

  void _fetchRoutes() async {
    if (isReadyToFetch()) {
      _routes = await _loadRoutes(
          _tariffs.map<String>((e) => e.key).toList(),
          _arrival!.type,
          _arrival!.id,
          _departure!.type,
          _departure!.id,
          prettyDate(_date!));
      notifyListeners();
    }
  }

  // Journey data
  List<Journey>? _journeys;
  List<Journey>? get journeys => _journeys;
  void _fetchJourneys() async {
    if (isReadyToFetch()) {
      _journeys = await _loadJourneys(_departure!.id, _arrival!.id, useCache);
      notifyListeners();
    }
  }

  // Search results data
  List<Place>? _placeSearchResults;
  List<Place>? get searchResults => _placeSearchResults;
  Future<List<Place>?> searchPlaces(String query) async {
    if (query == '') {
      return null;
    }
    _placeSearchResults =
        await _loadLocations(query, useCache, searchType ?? SearchType.origin);
    return _placeSearchResults;
  }

  // Search type
  SearchType? searchType;

  List<LocationS>? _allLocations;

  List<LocationS>? get allLocations => _allLocations;

  set allLocations(List<LocationS>? allLocations) {
    _allLocations = allLocations;
  }

  void _getAllLocations() async {
    _allLocations = await _loadLocationss("");
  }

  List<LocationS>? _locationSearchResults;
  List<LocationS>? get locationSearchResults => _locationSearchResults;
  Future<List<LocationS>?> getLocations(String query) async {
    if (query == '') {
      return null;
    }
    _locationSearchResults = await _loadLocationss(query);
    return _locationSearchResults;
  }

  Future<List<LocationS>?> locationSearchPlaces(String query) async {
    if (query == '') {
      return null;
    }
    _locationSearchResults = await _loadLocationss(query);
    return _locationSearchResults;
  }

  Future<Connection?> _loadConnection(List<String> list, String route,
      String arrivalStation, String departureStation) async {
    var a = api.getConnection(list, route, arrivalStation, departureStation);
    return a;
  }

  Future<List<SeatClass>?> _loadSeats() async {
    return api.getSeats();
  }
}

enum SearchType { origin, destination }

/// Preferences
class PrefsNotifier with ChangeNotifier {
  // Locale
  static const Map<int, Locale> supportedLanguages = {
    0: const Locale('en'),
    1: const Locale('de'),
  };

  // The selector value, which maps to supportedLanguages
  int _localeSelector = 0;
  int get localeSelector => _localeSelector;
  set localeSelector(int val) {
    assert(val >= 0 && val <= 1);
    _localeSelector = val;
    _locale = supportedLanguages[val] ?? Locale('en');
    notifyListeners();
  }

  Locale? _locale;
  Locale? get locale => _locale;
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

Future<List<Tariff>> _loadTariffs() => api.getTariffs();

Future<List<LocationS>> _loadLocationss(
  String query,
) =>
    api.getLocations(query);

/// Manage loading locations
Future<List<Place>> _loadLocations(
  String query,
  bool fromCache,
  SearchType locationType,
) =>
    fromCache
        ? (locationType == SearchType.origin
            ? cache.locationOrigin
            : cache.locationDestination)
        : api.locations(query);

/// Manage loading journeys
Future<List<Journey>> _loadJourneys(String originId, String destinationId,
        [bool fromCache = false]) =>
    fromCache ? cache.journey : api.journey(originId, destinationId);
Future<List<Route>> _loadRoutes(
        List<String> tariffs,
        String toLocationType,
        String toLocationId,
        String fromLocationType,
        String fromLocationId,
        String departureDate) =>
    api.getRoutes(tariffs, toLocationType, toLocationId, fromLocationType,
        fromLocationId, departureDate);
