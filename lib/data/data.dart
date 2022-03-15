// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../utils.dart';

/// Data types/models

class Coordinates {
  const Coordinates({required this.latitude, required this.longitude});
  final double latitude;
  final double longitude;
}

// class Country {
//   const Country({required this.name, required this.cities});
//   final String name;
//   final List<City> cities;
//   factory Country.fromJson(Map<String, dynamic> json) {
//     return Country(
//       name: json['country'] as String,
//       cities: [
//         if (json.containsKey('cities'))
//           for (var city in json['cities']) City.fromJson(city),
//       ],
//     );
//   }
// }

class WatchedEntity {
  WatchedEntity(
      {this.id,
      required this.userId,
      required this.routeId,
      required this.fromStationId,
      required this.toStationId,
      required this.tickets,
      required this.tariffs,
      required this.seatClasses,
      required this.arrivalTime,
      required this.type});
  final String? id;
  final String userId;
  final String routeId;
  final String fromStationId;
  final String toStationId;
  int tickets;
  List<String> tariffs;
  List<String> seatClasses;
  final DateTime arrivalTime;
  String type;

  factory WatchedEntity.fromJson(Map<String, dynamic> json) {
    return WatchedEntity(
        id: json['id'] as String,
        userId: json['userId'] as String,
        routeId: json['routeId'] as String,
        fromStationId: json['fromStationId'] as String,
        toStationId: json['toStationId'] as String,
        tickets: json['tickets'] as int,
        tariffs: [for (var tariff in json['tariffs']) tariff],
        seatClasses: [for (var seatClass in json['seatClasses']) seatClass],
        arrivalTime: DateTime.parse(json['arrivalTime'] as String),
        type: json['type'] as String);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'routeId': routeId,
        'fromStationId': fromStationId,
        'toStationId': toStationId,
        'tickets': tickets,
        'tariffs': tariffs,
        'seatClasses': seatClasses,
        'arrivalTime': arrivalTime.toString(),
        'type': type,
      };
}

class Route extends WithTypes {
  Route({
    required this.id,
    required this.departureStation,
    required this.departureTime,
    required this.arrivalStation,
    required this.arrivalTime,
    required this.transfers,
    required this.freeSeats,
    required this.minPrice,
    required this.maxPrice,
    required this.delay,
    required this.travelTime,
    required types,
  }) : super(types);

  final String id;
  final String departureStation;
  final DateTime departureTime;
  final String arrivalStation;
  final DateTime arrivalTime;
  final int transfers;
  final int freeSeats;
  final double minPrice;
  final double maxPrice;
  final String delay;
  final String travelTime;
  bool _isExpanded = false;

  bool get isExpanded => _isExpanded;

  set isExpanded(bool isExpanded) {
    _isExpanded = isExpanded;
  }

  factory Route.fromJson(Map<String, dynamic> json) {
    return Route(
      id: json['id'] as String,
      departureStation: json['departureStationId'] as String,
      departureTime: DateTime.parse(json['departureTime'] as String),
      arrivalStation: json['arrivalStationId'] as String,
      arrivalTime: DateTime.parse(json['arrivalTime'] as String),
      types: [
        for (var type in json['vehicleTypes'])
          stationTypeFromString(type.toLowerCase())
      ],
      transfers: json['transfersCount'] as int,
      freeSeats: json['freeSeatsCount'] as int,
      minPrice: (json['priceFrom'] as num).toDouble(),
      maxPrice: (json['priceTo'] as num).toDouble(),
      delay: json['delay'] == null ? "" : json['delay'] as String,
      travelTime: json['travelTime'] as String,
    );
  }
}

class Connection {
  Connection({
    required this.id,
    required this.priceClasses,
    required this.sections,
    required this.delay,
    required this.travelTime,
    required this.transfersInfo,
    required this.departureName,
    required this.arrivalName,
  });
  final String id;
  final List<PriceClass> priceClasses;
  final List<Section> sections;
  final String delay;
  final String travelTime;
  final TransfersInfo? transfersInfo;
  final String departureName;
  final String arrivalName;

  factory Connection.fromJson(Map<String, dynamic> json) {
    return Connection(
      id: json['id'] as String,
      priceClasses: [
        for (var price in json['priceClasses']) PriceClass.fromJson(price)
      ],
      sections: [
        for (var section in json['sections']) Section.fromJson(section)
      ],
      delay: json['delay'] == null ? "" : json['delay'] as String,
      travelTime: json['travelTime'] as String,
      transfersInfo: json['transfersInfo'] == null
          ? null
          : TransfersInfo.fromJson(json['transfersInfo']),
      arrivalName: (json['arrivalCityName'] as String) +
          ',' +
          (json['arrivalStationName'] as String),
      departureName: (json['departureCityName'] as String) +
          ',' +
          (json['departureStationName'] as String),
    );
  }
}

class Transfer {
  Transfer({
    required this.time,
  });
  final Duration time;

  factory Transfer.fromJson(Map<String, dynamic> json) {
    return Transfer(
        time: Duration(
            days: json['calculatedTransferTime']['days'] as int,
            hours: json['calculatedTransferTime']['hours'] as int,
            minutes: json['calculatedTransferTime']['minutes'] as int));
  }
}

class TransfersInfo {
  TransfersInfo({
    required this.info,
    required this.transfers,
  });
  final String info;
  final List<Transfer> transfers;

  factory TransfersInfo.fromJson(Map<String, dynamic> json) {
    return TransfersInfo(info: json['info'] as String, transfers: [
      for (var transfer in json['transfers']) Transfer.fromJson(transfer)
    ]);
  }
}

class PriceClass {
  PriceClass({
    required this.id,
    required this.price,
    required this.freeSeats,
  });

  final String id;
  final double price;
  final int freeSeats;

  factory PriceClass.fromJson(Map<String, dynamic> json) {
    return PriceClass(
        id: json['seatClassKey'] as String,
        price: json['price'] as double,
        freeSeats: json['freeSeatsCount'] as int);
  }
}

class Line2 {
  Line2({
    required this.id,
    required this.code,
    required this.line,
    required this.from,
    required this.to,
  });
  final String id;
  final String code;
  final String line;
  final String from;
  final String to;

  getLine() =>
      line.contains('_') ? line.split('_')[0].capitalize() : line.capitalize();

  factory Line2.fromJson(Map<String, dynamic> json) {
    return Line2(
      id: json['id'] as String,
      code: json['code'] == null ? "" : json['code'] as String,
      line: json['line'] as String,
      from: json['from'] as String,
      to: json['to'] as String,
    );
  }
}

class Section {
  Section({
    required this.id,
    required this.departureStationId,
    // required this.departureCityName,
    required this.departureName,
    // required this.departureStationName,
    required this.departureTime,
    required this.arrivalStationId,
    required this.arrivalName,
    // required this.arrivalCityName,
    // required this.arrivalStationName,
    required this.arrivalTime,
    required this.freeSeats,
    required this.delay,
    required this.line,
    required this.travelTime,
    required this.type,
  });
  final String id;
  final String departureStationId;
  final String departureName;
  final DateTime departureTime;
  final String arrivalStationId;
  final String arrivalName;
  final DateTime arrivalTime;
  final int freeSeats;
  final String delay;
  final Line2 line;
  final String travelTime;
  final StationType type;

  getType() => type.toString().replaceAll(r'StationType.', '');

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'] as String,
      departureStationId: json['id'] as String,
      arrivalName: (json['arrivalCityName'] as String) +
          ',' +
          (json['arrivalStationName'] as String),
      departureTime: DateTime.parse(json['departureTime'] as String),
      arrivalStationId: json['id'] as String,
      departureName: (json['departureCityName'] as String) +
          ',' +
          (json['departureStationName'] as String),
      arrivalTime: DateTime.parse(json['arrivalTime'] as String),
      freeSeats: json['freeSeatsCount'] as int,
      delay: json['delay'] == null ? "" : json['delay'] as String,
      line: Line2.fromJson(json['line']),
      travelTime: json['travelTime'] as String,
      type:
          stationTypeFromString((json['vehicleType'] as String).toLowerCase()),
    );
  }
}

class Tariff {
  const Tariff({required this.key, required this.description});
  final String key;
  final String description;

  @override
  bool operator ==(Object other) => other is Tariff && other.key == key;

  @override
  int get hashCode => key.hashCode;

  factory Tariff.fromJson(Map<String, dynamic> json) {
    return Tariff(
      key: json['key'] as String,
      description: json['value'] as String,
    );
  }
}

class SeatClass {
  const SeatClass(
      {required this.key, required this.title, required this.description});
  // final String vehicleClass;
  final String key;
  final String title;
  final String description;

  factory SeatClass.fromJson(Map<String, dynamic> json) {
    return SeatClass(
      // vehicleClass: json['vehicleClass'] as String,
      key: json['key'] as String,
      title: json['title'] as String,
      description:
          json['description'] == null ? "" : json['description'] as String,
    );
  }
}

abstract class LocationS extends WithTypes {
  const LocationS({required this.id, required this.name, required types})
      : super(types);
  final String id;
  final String name;
  String get type => this is City ? "CITY" : "STATION";
}

class City extends LocationS {
  const City(
      {required id,
      required name,
      required types,
      required this.country,
      required this.stations})
      : super(id: id, name: name, types: types);
  final String country;
  final List<Station> stations;

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] as String,
      name: json['name'] as String,
      types: [
        for (var type in json['stationsTypes'])
          stationTypeFromString(type.toLowerCase())
      ],
      country: json['country'] as String,
      stations: [
        if (json.containsKey('stations'))
          for (var station in json['stations']) Station.fromJson(station),
      ],
    );
  }
}

class Station extends LocationS {
  const Station(
      {required id,
      required name,
      required types,
      required this.fullName,
      required this.coordinates})
      : super(id: id, name: fullName, types: types);
  final String fullName;
  final Coordinates coordinates;

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'] as String,
      name: json['name'] as String,
      fullName: json['fullname'] as String,
      types: [
        for (var type in json['stationsTypes'])
          stationTypeFromString(type.toLowerCase())
      ],
      coordinates: Coordinates(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
      ),
    );
  }
}

/// Data type for latitude/longitude
class LatLng {
  const LatLng({required this.lat, required this.lng});
  final double lat;
  final double lng;
}

/// Data type for locations
class Place {
  const Place({required this.id, this.name, this.coordinates});
  final String id;
  final String? name;
  final LatLng? coordinates;

  factory Place.fromJson(Map<String, dynamic> json) {
    assert(json.containsKey('type') &&
        ['location', 'stop'].contains(json['type']));
    return (json['type'] == 'location')
        ? Location.fromJson(json)
        : Stop.fromJson(json);
  }
}

class Location extends Place {
  const Location({
    required String id,
    required String name,
    required LatLng coordinates,
  }) : super(id: id, name: name, coordinates: coordinates);

  factory Location.fromJson(Map<String, dynamic> json) {
    // Return null if id or name keys are missing
    if (!json.keys.contains('id') || !json.keys.contains('name'))
      throw FormatException('Incorrectly formatted location json');
    // return null;

    if (json['type'] == 'location')
      return Location(
        id: json['id'] as String,
        name: json['name'] as String,
        coordinates: LatLng(
          lat: (json['latitude'] as num).toDouble(),
          lng: (json['longitude'] as num).toDouble(),
        ),
      );
    return Location.fromJson(json);
  }
}

/// A transport line or route
class Line {
  const Line({
    this.id,
    this.name,
    required this.type,
    required this.mode,
  });
  final String? id;
  final String? name;
  final StopType type;
  final Mode mode;

  factory Line.fromJson(Map<String, dynamic> json) {
    assert(json.containsKey('type') && json['type'] == 'line');
    return Line(
      id: json['id'] as String,
      name: json['name'] as String,
      type: _stopTypeFromString(json['product']),
      mode: _modeTypeFromString(json['mode']),
    );
  }
}

/// Data type for a transportation stop
class Stop extends Place {
  const Stop({
    required String id,
    required String name,
    required LatLng coordinates,
    required this.types,
    required this.lines,
  }) : super(id: id, name: name, coordinates: coordinates);
  final List<StopType> types;
  final List<Line> lines;

  /// Converts enums to strings
  Iterable<String> get typesAsStrings =>
      types.map<String>((t) => t.toString().replaceAll(r'StopType.', ''));

  factory Stop.fromJson(Map<String, dynamic> json) {
    assert(json.containsKey('type') && json['type'] == 'stop');
    return Stop(
      id: json['id'] as String,
      name: json['name'] as String,
      coordinates: LatLng(
        lat: (json['location']['latitude'] as num).toDouble(),
        lng: (json['location']['longitude'] as num).toDouble(),
      ),
      types: [
        for (var productKey in json['products'].keys)
          if (json['products'][productKey]) _stopTypeFromString(productKey)
      ],
      lines: [
        if (json.containsKey('lines'))
          for (var line in json['lines']) Line.fromJson(line),
      ],
    );
  }
}

/// Types of transportation stops
enum StopType {
  suburban,
  subway,
  tram,
  bus,
  ferry,
  express,
  regional,
}

/// Converts stop type string to enums
StopType _stopTypeFromString(String str) =>
    StopType.values.firstWhere((e) => e.toString() == 'StopType.$str');

/// Modes of transportation
enum Mode {
  bus,
  train,
  walking,
}

/// Converts mode string to enums
Mode _modeTypeFromString(String str) =>
    Mode.values.firstWhere((e) => e.toString() == 'Mode.$str');

class Journey {
  const Journey({required this.legs});
  final List<Leg> legs;

  factory Journey.fromJson(Map<String, dynamic> json) {
    assert(json.containsKey('type') && json['type'] == 'journey');
    return Journey(
      legs: [for (var leg in json['legs']) Leg.fromJson(leg)],
    );
  }
}

class Leg {
  const Leg({
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
    this.line,
    this.direction,
  });
  final Stop origin;
  final Stop destination;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final Line? line;
  final String? direction;

  factory Leg.fromJson(Map<String, dynamic> json) => Leg(
        origin: Stop.fromJson(json['origin']),
        destination: Stop.fromJson(json['destination']),
        departureTime: DateTime.parse(json['departure']),
        arrivalTime: DateTime.parse(json['arrival']),
        line: json.containsKey('line') ? Line.fromJson(json['line']) : null,
        direction: json['direction'],
      );

  @override
  bool operator ==(obj) =>
      obj is Leg &&
      departureTime == obj.departureTime &&
      arrivalTime == obj.arrivalTime;

  @override
  int get hashCode => departureTime.hashCode ^ arrivalTime.hashCode;
}
