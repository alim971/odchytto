import 'package:watcher/common/data/data.dart';
import 'package:watcher/common/extensions/extensions.dart';

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
      required this.departureTime,
      required this.type,
      required this.url});
  final String? id;
  final String userId;
  final String routeId;
  final String fromStationId;
  final String toStationId;
  int tickets;
  List<String> tariffs;
  List<String> seatClasses;
  final DateTime arrivalTime;
  final DateTime departureTime;
  String type;
  String url;
  bool isExpanded = false;

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
      departureTime: DateTime.parse(json['departureTime'] as String),
      type: json['type'] as String,
      url: json['url'] as String,
    );
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
        'departureTime': departureTime.toString(),
        'type': type,
        'url': url,
      };
}

class RouteTransport extends WithTypes {
  RouteTransport({
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
  bool isExpanded = false;

  factory RouteTransport.fromJson(Map<String, dynamic> json) {
    return RouteTransport(
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

  factory RouteTransport.fromConnection(Connection connection) {
    return RouteTransport(
        id: connection.id,
        departureStation: connection.departureStationId,
        departureTime: connection.departureTime,
        arrivalStation: connection.arrivalStationId,
        arrivalTime: connection.arrivalTime,
        types: connection.types,
        transfers: connection.sections.length - 1,
        freeSeats: connection.freeSeats,
        minPrice: connection.minPrice,
        maxPrice: connection.maxPrice,
        delay: connection.delay,
        travelTime: connection.travelTime);
  }
}

class Connection extends WithTypes {
  Connection({
    required this.id,
    required this.priceClasses,
    required this.sections,
    required this.delay,
    required this.travelTime,
    required this.transfersInfo,
    required this.departureName,
    required this.arrivalName,
    required this.arrivalStationId,
    required this.departureStationId,
    required this.arrivalTime,
    required this.departureTime,
    required this.minPrice,
    required this.maxPrice,
    required this.freeSeats,
    required types,
  }) : super(types);
  final String id;
  final List<PriceClass> priceClasses;
  final List<Section> sections;
  final String delay;
  final String travelTime;
  final TransfersInfo? transfersInfo;
  final String departureName;
  final String departureStationId;
  final DateTime departureTime;
  final String arrivalName;
  final String arrivalStationId;
  final DateTime arrivalTime;
  final double minPrice;
  final double maxPrice;
  final int freeSeats;

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
      departureStationId: json['departureStationId'] as String,
      departureTime: DateTime.parse(json['departureTime'] as String),
      arrivalStationId: json['arrivalStationId'] as String,
      arrivalTime: DateTime.parse(json['arrivalTime'] as String),
      types: [
        for (var type in json['vehicleTypes'])
          stationTypeFromString(type.toLowerCase())
      ],
      minPrice: (json['priceFrom'] as num).toDouble(),
      maxPrice: (json['priceTo'] as num).toDouble(),
      freeSeats: json['freeSeatsCount'] as int,
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

class TariffWithCounter {
  TariffWithCounter(this.tariff, this._count);
  Tariff tariff;
  int _count;

  int get count => _count;

  String get description => tariff.description;
  String get key => tariff.key;

  set count(int count) {
    if (count >= 0) _count = count;
  }

  @override
  bool operator ==(Object other) =>
      other is TariffWithCounter && other.key == key;

  @override
  int get hashCode => key.hashCode;
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
  SeatClass(
      {required this.key, required this.title, required this.description});
  // final String vehicleClass;
  final String key;
  String title;
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

abstract class Location extends WithTypes {
  const Location({required this.id, required this.name, required types})
      : super(types);
  final String id;
  final String name;
  String get type => this is City ? "CITY" : "STATION";
}

class City extends Location {
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

class Station extends Location {
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
