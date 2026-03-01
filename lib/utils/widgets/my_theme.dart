import 'package:flutter/material.dart';

class MyThemes {
  static BoxShadow lightThemeShadow =      const BoxShadow(
    color: Color(
        0x33959DA5), // 20% opacity color
    blurRadius: 24,
    spreadRadius: 0,
    offset: Offset(0, 8),
  );

  static BoxShadow darkThemeShadow =
  const BoxShadow(
  color: Color(
  0x4D000000), // 30% opacity color
  blurRadius: 30,
  spreadRadius: 0,
  offset: Offset(0, 4),
  );

}
class MyThemesFilter {
  static BoxShadow lightThemeShadow =      const BoxShadow(
    color: Color(
        0x33959DA5), // 20% opacity color
    blurRadius: 14,
    spreadRadius: 0,
    offset: Offset(0, 8),
  );

  static BoxShadow darkThemeShadow =
  const BoxShadow(
    color: Color(
        0x4D000000), // 30% opacity color
    blurRadius: 20,
    spreadRadius: 0,
    offset: Offset(0, 4),
  );

}