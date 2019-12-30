import 'package:flutter/material.dart';
import 'package:oraculo/controllers/appointment_controller.dart';
import 'package:oraculo/themes.dart';
import 'package:provider/provider.dart';
import 'views/home_view.dart';

void main() => runApp(OraculoApp());

class OraculoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppointmentController>.value(
          value: AppointmentController(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Oráculo meeting room schedule',
        theme: DefaultTheme().mainTheme(),
        home: HomeView(),
      ),
    );
  }
}
