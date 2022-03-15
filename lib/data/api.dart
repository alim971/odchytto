// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// See https://github.com/derhuerst/bvg-rest/blob/master/docs/index.md
/// for api info
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:watcher/data/data.dart';

import '../utils.dart';

class LatLng {
  const LatLng({required this.lat, required this.lng});
  final double lat;
  final double lng;
}

const cityCubeBerlin = LatLng(lat: 52.523430, lng: 13.411440);
const urlPrefix = 'https://v5.bvg.transport.rest';
const urlPrefi = 'http://localhost:8080/api/v1';

List<LocationS> getCities(Iterable<City>? cities) {
  List<LocationS> _cities = [];
  if (cities != null) {
    for (City city in cities) {
      _cities.add(city);
      for (Station station in city.stations) {
        _cities.add(station);
      }
    }
  }

  return _cities;
}

Future<List<Tariff>> getTariffs() async {
  final url = urlPrefi + '/regio/tariffs';
  final body = await _fetchData(url);
  return (json.decode(body) as List)
      .map<Tariff>((t) => Tariff.fromJson(t))
      .toList();
}

Future<List<SeatClass>> getSeats() async {
  final url = urlPrefi + '/regio/seats';
  final body = await _fetchData(url);
  return (json.decode(body) as List)
      .map<SeatClass>((s) => SeatClass.fromJson(s))
      .toList();
}

Future<List<LocationS>> getLocations(String query) async {
  final url = urlPrefi + '/regio/locations';
  query = doctor(query);
  final body = await _fetchData(url);
  return getCities(
          (json.decode(body) as List).map<City>((city) => City.fromJson(city)))
      .where((location) => doctor(location.name).contains(query))
      .toList();
}

Future<Connection> getConnection(
  List<String> tariffs,
  String routeId,
  String toStationId,
  String fromStationId,
) async {
  String tariffsQuery = "";
  for (String tariff in tariffs) {
    tariffsQuery += 'tariffs=$tariff&';
  }
  final url = urlPrefi +
      '/regio/route?$tariffsQuery' +
      'routeId=$routeId&fromStationId=$fromStationId&toStationId=$toStationId';
  final body = await _fetchData(url);
  return Connection.fromJson(json.decode(body) as Map<String, dynamic>);
}

Future<List<Route>> getRoutes(
  List<String> tariffs,
  String toLocationType,
  String toLocationId,
  String fromLocationType,
  String fromLocationId,
  String departureDate,
) async {
  String tariffsQuery = "";
  for (String tariff in tariffs) {
    tariffsQuery += 'tariffs=$tariff&';
  }
  final url = urlPrefi +
      '/regio/routes?$tariffsQuery' +
      'toLocationType=$toLocationType&toLocationId=$toLocationId' +
      '&fromLocationType=$fromLocationType&fromLocationId=$fromLocationId' +
      '&departureDate=$departureDate';
  print(url);
  final body = await _fetchData(url);
  return (json.decode(body) as Map<String, dynamic>)['routes']
      .map<Route>((j) => Route.fromJson(j))
      .toList();
}

/// Retrieves all stations near a given position
///
/// curl 'https://1.bvg.transport.rest/stations/nearby?latitude=52.52725&longitude=13.4123'
Future<String> nearbyStations(LatLng latLng) async {
  final url = urlPrefix +
      '/stations/nearby' +
      '?latitude=${latLng.lat}' +
      '&longitude=${latLng.lng}';

  return _fetchData(url);
}

/// Retrieves data regarding the specified station
///
/// curl 'https://1.bvg.transport.rest/stations/900000013102'
Future<String> station(int id) async {
  final url = urlPrefix + '/stations/$id';
  return _fetchData(url);
}

/// Retrieves current departures for a station
///
/// curl 'https://1.bvg.transport.rest/stations/900000013102/departures?when=tomorrow%206pm'
Future<String> departures(int stationId) async {
  final url = urlPrefix + '/stations/$stationId/departures';
  return _fetchData(url);
}

/// Retrieves journey data from and to specified stations
///
/// curl 'https://1.bvg.transport.rest/journeys?from=900000017104&to=900000017101'
Future<List<Journey>> journey(String fromId, String toId) async {
  final url = urlPrefix + '/journeys?from=$fromId&to=$toId';
  print(url);
  final body = await _fetchData(url);
  return (json.decode(body) as Map<String, dynamic>)['journeys']
      .map<Journey>((j) => Journey.fromJson(j))
      .toList();
}

/// Searches for locations given a query string
///
/// curl 'https://1.bvg.transport.rest/locations?query=citycube'
Future<List<Place>> locations(String query) async {
  final url = urlPrefix +
      '/locations?query=$query' +
      '&stationLines=true' +
      '&results=10';
  final body = await _fetchData(url);
  return (json.decode(body) as List)
      .map<Place>((p) => Place.fromJson(p))
      .where((p) => p != null) // filter out nulls
      .toList();
}

/// Fetches data from a url over http
/// Throws a HttpException if 200 is not returned
Future<String> _fetchData(String url) async {
  final res = await http.get(Uri.parse(url));

  if (res.statusCode != 200) {
    print('Error ${res.statusCode}: $url');
    throw HttpException(
      'Invalid response ${res.statusCode}',
      uri: Uri.parse(url),
    );
  }
  return res.body;
}

Future<WatchedEntity> postEntity(WatchedEntity entity) async {
  String url = urlPrefi + '/regio/watch';
  final body = await _postData(url, entity);
  return WatchedEntity.fromJson(json.decode(body) as Map<String, dynamic>);
}

Future<bool> deleteEntity(String id) async {
  String url = urlPrefi + '/regio/watch/$id';
  // final body = await _fetchData(url);
  // var entity =
  //     WatchedEntity.fromJson(json.decode(body) as Map<String, dynamic>);
  return await _delete(url);
}

Future<WatchedEntity?> getEntity(String id) async {
  String url = urlPrefi + '/regio/watch/$id';
  final res = await http.get(Uri.parse(url));
  if (res.statusCode != 200) {
    return null;
  }
  return WatchedEntity.fromJson(json.decode(res.body) as Map<String, dynamic>);
}

Future<bool> _delete(String url) async {
  final res = await http.delete(Uri.parse(url));
  if (res.statusCode != 200 && res.statusCode != 404) {
    print('Error ${res.statusCode}: $url');
    throw HttpException(
      'Invalid response ${res.statusCode}',
      uri: Uri.parse(url),
    );
  }
  return true;
}

Future<String> _postData(String url, dynamic data) async {
  final res = await http.post(Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data));
  if (res.statusCode != 201) {
    print('Error ${res.statusCode}: $url');
    throw HttpException(
      'Invalid response ${res.statusCode}',
      uri: Uri.parse(url),
    );
  }
  return res.body;
}
