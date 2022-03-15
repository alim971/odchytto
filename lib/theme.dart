// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

const berlinBrightYellow = Color(0xFFFFD300);
const berlinDarkYellow = Color(0xFFFFB900);
const grey = Color(0xD8787878);

final appBarTheme = AppBarTheme(
  elevation: 0,
  color: berlinBrightYellow,
  foregroundColor: Colors.black,
);

final ThemeData theme = ThemeData();
final appTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: berlinBrightYellow,
  colorScheme: theme.colorScheme.copyWith(secondary: berlinDarkYellow),
  appBarTheme: appBarTheme,
  elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          primary: berlinDarkYellow,
          onPrimary: Colors.black,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)))),

  // Define the default Font Family
  fontFamily: 'Montserrat',

  // Define the default TextTheme. Use this to specify the default
  // text styling for headlines, titles, bodies of text, and more.
  textTheme: TextTheme(
    displaySmall: TextStyle(color: Colors.black),
    displayLarge: TextStyle(
      fontSize: 36,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),

    //headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
    //title: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
    //body1: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
  ),
);
