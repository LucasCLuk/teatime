import 'package:flutter/material.dart';

final Map<int, ThemeData> appThemes = {
  0: lightTheme(),
  1: darkTheme(),
};

ThemeData darkTheme() {
  return ThemeData(
      fontFamily: "Gothic",
      brightness: Brightness.dark,
      accentColor: Color(0xFFFC6047),
      accentColorBrightness: Brightness.light,
      primaryColor: Color(0xFF28282D),
      primaryColorLight: Color(0xFF5f606a),
      primaryColorDark: Color(0xFF0f1019),
      cardColor: Color(0xFF35363F));
}

ThemeData lightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    fontFamily: "Gothic",
    primaryColor: Color(0xFFffae18),
    accentColor: Color(0xFF5d18ff),
  );
}
