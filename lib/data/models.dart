// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Middleware that manages interactions between ui and api
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:watcher/data/api.dart' as api;
import 'package:watcher/data/cache.dart' as cache;
import 'package:watcher/data/data.dart';

/// Journey data
class JourneyNotifier with ChangeNotifier {
  // Cache flag
  var _useCache = false;
  bool get useCache => _useCache;
  set useCache(bool val) {
    _useCache = val;
    notifyListeners();
  }

  // Depature data
  LocationS? _departure;
  LocationS? get departure => _departure;
  set departure(LocationS? place) {
    _departure = place;
    _fetchJourneys();
    notifyListeners();
  }

  // Arrival data
  LocationS? _arrival;
  LocationS? get arrival => _arrival;
  set arrival(LocationS? place) {
    _arrival = place;
    _fetchJourneys();
    notifyListeners();
  }

  // Journey data
  List<Journey>? _journeys;
  List<Journey>? get journeys => _journeys;
  void _fetchJourneys() async {
    if (_departure != null && _arrival != null) {
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

  List<LocationS>? _locationSearchResults;
  List<LocationS>? get locationSearchResults => _locationSearchResults;
  Future<List<LocationS>?> locationSearchPlaces(String query) async {
    if (query == '') {
      return null;
    }
    _locationSearchResults = await _loadLocationss(query);
    return _locationSearchResults;
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
