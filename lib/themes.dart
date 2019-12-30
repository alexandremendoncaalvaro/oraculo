import 'package:flutter/material.dart';

class DefaultTheme {
  ThemeData mainTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      primaryColor: Colors.blue,
      accentColor: Colors.white,
    );
  }
  Color primaryColorFreeRoom = Colors.green;
  Color primaryColorBusyRoom = Colors.red;
  Color primaryColorReadyToCheckinRoom = Colors.blue;
  Color primaryColorCancelledRoom = Colors.green;
}
