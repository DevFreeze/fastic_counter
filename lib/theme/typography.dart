import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  static final textTheme =
    TextTheme(
      headline1: TextStyle(
        debugLabel: "headline1",
        fontFamily: "Lato",
        fontSize: 50,
        color: Color.fromRGBO(31, 52, 85, 1),
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.normal,
      ),
      headline2: TextStyle(
        debugLabel: "headline2",
        fontFamily: "Lato",
        fontSize: 24,
        color: Color.fromRGBO(31, 52, 85, 1),
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.normal,
      ),
      headline3: TextStyle(
        debugLabel: "headline3",
        fontFamily: "Lato",
        fontSize: 14,
        color: Color.fromRGBO(31, 52, 85, 1),
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.normal,
      ),
      headline4: TextStyle(
        debugLabel: "headline4",
        fontFamily: "Lato",
        fontSize: 14,
        color: Color.fromRGBO(31, 52, 85, 1),
        fontWeight: FontWeight.normal,
        fontStyle: FontStyle.normal,
      ),
      button: TextStyle(
        debugLabel: "button",
        fontFamily: "Lato",
        fontSize: 14,
        color: Color.fromRGBO(31, 52, 85, 1),
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.normal,
      ),
  );
}
