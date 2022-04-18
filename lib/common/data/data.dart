// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Data types/models

class Currency {
  const Currency({required this.code, required this.name});
  final String code;
  final String name;
}

class Coordinates {
  const Coordinates({required this.latitude, required this.longitude});
  final double latitude;
  final double longitude;
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
