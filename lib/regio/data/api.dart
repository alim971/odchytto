import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:watcher/common/data/api.dart';
import 'package:watcher/common/utils/utils.dart';
import 'package:watcher/regio/data/data.dart';

const urlPrefix = //'http://10.0.2.2:8080/api/v1/regio';
    'http://prod.eba-zjyvrrrk.eu-central-1.elasticbeanstalk.com/api/v1/regio';
const Duration constants = Duration(hours: 12);
const Duration constantsStale = Duration(hours: 24);
const Duration changing = Duration(minutes: 5);

class DioRegioWrapper {
  static final DioRegioWrapper _singleton = DioRegioWrapper._internal();

  factory DioRegioWrapper() {
    _singleton.dio.interceptors
        .add(DioCacheManager(CacheConfig(baseUrl: urlPrefix)).interceptor);
    return _singleton;
  }

  DioRegioWrapper._internal();
  Dio dio = Dio();
}

List<Location> _getCities(Iterable<City>? cities) {
  List<Location> _cities = [];
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

// Future<void> setCurrency(String currency) async {
//   postData(urlPrefix + '/currency/' + currency, "");
// }
//
// Future<void> setLanguage(String language) async {
//   postData(urlPrefix + '/lang/' + language, "");
// }

Future<List<Tariff>> getTariffs(String language, String currency) async {
  final url = '$urlPrefix/tariffs?language=$language&currency=$currency';
  final body = await fetchData(url, DioRegioWrapper().dio, constants,
      timeToStale: constantsStale);
  return (body.data as List).map<Tariff>((t) => Tariff.fromJson(t)).toList();
}

Future<List<SeatClass>> getSeats(String language, String currency) async {
  final url = '$urlPrefix/seats?language=$language&currency=$currency';
  final body = await fetchData(url, DioRegioWrapper().dio, constants,
      timeToStale: constantsStale);
  return (body.data as List)
      .map<SeatClass>((s) => SeatClass.fromJson(s))
      .toList();
}

Future<List<Location>> getLocations(
    String query, String language, String currency) async {
  final url = '$urlPrefix/locations?language=$language&currency=$currency';
  query = doctor(query);
  final body = await fetchData(url, DioRegioWrapper().dio, constants,
      timeToStale: constantsStale);
  return _getCities(
          (body.data as List).map<City>((city) => City.fromJson(city)))
      .where((location) => doctor(location.name).contains(query))
      .toList();
}

Future<Connection> getConnection(
    List<String> tariffs,
    String routeId,
    String toStationId,
    String fromStationId,
    String language,
    String currency) async {
  String tariffsQuery = "";
  for (String tariff in tariffs) {
    tariffsQuery += 'tariffs=$tariff&';
  }
  final url = urlPrefix +
      '/route?$tariffsQuery' +
      'routeId=$routeId&fromStationId=$fromStationId&toStationId=$toStationId' +
      '&language=$language&currency=$currency';
  final body = await fetchData(url, DioRegioWrapper().dio, changing);
  return Connection.fromJson(body.data as Map<String, dynamic>);
}

Future<List<RouteTransport>> getRoutes(
    List<String> tariffs,
    String toLocationType,
    String toLocationId,
    String fromLocationType,
    String fromLocationId,
    String departureDate,
    String language,
    String currency,
    {bool forceRefresh = false}) async {
  String tariffsQuery = "";
  for (String tariff in tariffs) {
    tariffsQuery += 'tariffs=$tariff&';
  }
  final url = urlPrefix +
      '/routes?$tariffsQuery' +
      'toLocationType=$toLocationType&toLocationId=$toLocationId' +
      '&fromLocationType=$fromLocationType&fromLocationId=$fromLocationId' +
      '&departureDate=$departureDate&language=$language&currency=$currency';
  // print(url);
  final body = await fetchData(url, DioRegioWrapper().dio, changing,
      timeToStale: changing, forceRefresh: forceRefresh);
  return (body.data as Map<String, dynamic>)['routes']
      .map<RouteTransport>((j) => RouteTransport.fromJson(j))
      .toList();
}

Future<WatchedEntity?> getEntity(String id) async {
  String url = urlPrefix + '/watch/$id';
  try {
    final body = await fetchData(
      url,
      DioRegioWrapper().dio,
      const Duration(seconds: 15),
    );
    return WatchedEntity.fromJson(body.data as Map<String, dynamic>);
  } catch (e) {
    return null;
  }
}

Future<WatchedEntity> postEntity(WatchedEntity entity) async {
  String url = urlPrefix + '/watch';
  final body = await postData(url, entity);
  return WatchedEntity.fromJson(json.decode(body) as Map<String, dynamic>);
}

Future<bool> deleteEntity(String id) async {
  String url = urlPrefix + '/watch/$id';
  // final body = await _fetchData(url);
  // var entity =
  //     WatchedEntity.fromJson(json.decode(body) as Map<String, dynamic>);
  return await delete(url);
}
