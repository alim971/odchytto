// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

String prettyTime(DateTime time) => DateFormat('HH:mm').format(time.toLocal());
String prettyDate(DateTime date) =>
    DateFormat('yyyy-MM-dd').format(date.toLocal());
String prettyDateTime(DateTime date) =>
    DateFormat('yyyy-MM-dd HH:mm').format(date);
String doctor(String s) => removeDiacritics(s.toLowerCase());
String format(Duration d) =>
    d.toString().split('.').first.padLeft(8, "0").substring(0, 5) + ' h';

showWatchDialog(
  Route route,
  String departureStation,
  String arrivalStation,
  Iterable<String> tarrifs,
) {}

launchURLApp(String routeId, String fromStationId, String toStationId,
    Iterable<String> tariffs, String seatClass) async {
  String tariffsQuery = "";
  for (String tariff in tariffs) {
    tariffsQuery += 'tariffs=$tariff&';
  }
  const String baseUrl = "https://novy.regiojet.cz/reservation/seating/";
  String query =
      "there?routeId=$routeId&fromStationId=$fromStationId&toStationId=$toStationId&$tariffsQuery"
      "seatClassKey=$seatClass";
  String url = baseUrl + query;
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

enum StationType {
  bus,
  train,
}

/// Converts stop type string to enums
StationType stationTypeFromString(String str) => StationType.values
    .firstWhere((e) => 'StationType.$str'.contains(e.toString()));

class WithTypes {
  const WithTypes(this.types);

  final List<StationType> types;

  Iterable<String> get typesAsStrings =>
      types.map<String>((t) => t.toString().replaceAll(r'StationType.', ''));
}

List<Icon> getIcons(WithTypes location) {
  List<Icon> icons = [];
  var types = location.typesAsStrings;
  if (types.contains('train')) {
    icons.add(const Icon(Icons.train));
  }
  if (types.contains('bus')) {
    icons.add(const Icon(Icons.directions_bus));
  }
  return icons;
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}

class RouteInfo extends StatelessWidget {
  RouteInfo(
      {required this.departureName,
      required this.arrivalName,
      required this.departureTime,
      required this.arrivalTime});

  final String departureName;
  final String arrivalName;
  final DateTime departureTime;
  final DateTime arrivalTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            PlaceName(departureName, size: 0.3),
            PlaceName(arrivalName, size: 0.3),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            PlaceName(prettyDateTime(departureTime.toLocal()),
                highlight: false, size: 0.3),
            PlaceName(prettyDateTime(arrivalTime.toLocal()),
                highlight: false, size: 0.3),
          ]),
        ),
      ],
    );
  }
}

class PlaceName extends StatelessWidget {
  const PlaceName(this.name, {this.highlight = true, this.size = 1.0});
  final String name;
  final bool highlight;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width * size,
        child: Text(
          name,
          style: TextStyle(
            fontSize: highlight ? 16 : 13,
            fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
