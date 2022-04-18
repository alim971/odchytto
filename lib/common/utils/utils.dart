// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:watcher/common/data/data.dart';

String prettyTime(DateTime time) => DateFormat('HH:mm').format(time.toLocal());
String prettyDate(DateTime date) =>
    DateFormat('yyyy-MM-dd').format(date.toLocal());
String prettyDateTime(DateTime date) =>
    DateFormat('yyyy-MM-dd HH:mm').format(date.toLocal());
String doctor(String s) => removeDiacritics(s.toLowerCase());
String format(Duration d) =>
    d.toString().split('.').first.padLeft(8, "0").substring(0, 5) + ' h';

launchUrlApp(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
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
