import 'package:flutter/material.dart';

const brightRegioYellow = Color(0xFFFFD300);
const darkRegioYellow = Color(0xFFFFB900);
const grey = Color(0xD8787878);

const appBarTheme = AppBarTheme(
  elevation: 0,
  color: brightRegioYellow,
  foregroundColor: Colors.black,
);

final ThemeData theme = ThemeData();
final appTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: brightRegioYellow,
  colorScheme: theme.colorScheme.copyWith(secondary: darkRegioYellow),
  appBarTheme: appBarTheme,
  elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          primary: darkRegioYellow,
          onPrimary: Colors.black,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)))),

  // Define the default Font Family
  fontFamily: 'Montserrat',

  // Define the default TextTheme. Use this to specify the default
  // text styling for headlines, titles, bodies of text, and more.
  textTheme: const TextTheme(
    displaySmall: TextStyle(color: Colors.black),
    displayLarge: TextStyle(
      fontSize: 36,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
  ),
);
