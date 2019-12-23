import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oraculo/my_room_occupation.dart';
import 'package:oraculo/my_schedule_card.dart';
import 'package:oraculo/appointment.dart';
import 'package:intl/intl.dart';

void main() => runApp(MyApp());

ThemeData myTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    primaryColor: Colors.blue,
    accentColor: Colors.white,
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var materialApp = MaterialApp(
      title: 'Oráculo Meeting Rooms',
      debugShowCheckedModeBanner: false,
      theme: myTheme(),
      home: MyHomePage(),
    );
    return materialApp;
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Timer rerenderTimer;
  @override
  initState() {
    super.initState();
    something();
    rerenderTimer = Timer.periodic(Duration(seconds: 1), (_) => something());
  }

  void something() {
    // http call
    // parse response
    // setState()
    setState(() {});
  }

  @override
  dispose() {
    super.dispose();
    rerenderTimer.cancel();
  }

  Widget myLayoutWidget() {
    var currentStatusText = "LIVRE";
    var currentStatusBackgroundColor = Colors.green;
    var checkinButton = Container(
      child: MyRoomCheckinButton('fazer check-in'),
    );
    void checkCurrentRoomStatus() {
      final schedule = Appointments(appointments).getSchedule();
      var now = DateTime.now();
      AppointmentData currentAppointment = schedule
          .where((a) => a.startTime.isBefore(now) & a.endTime.isAfter(now))
          .first;
      if (currentAppointment.subject != "Livre") {
        var blankContainer = Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '${DateFormat.Hm().format(currentAppointment.startTime)} - ${DateFormat.Hm().format(currentAppointment.endTime)}',
                style: TextStyle(
                  fontSize: 22,
                ),
              ),
              Text(
                currentAppointment.subject,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
        currentStatusText = 'OCUPADA';
        currentStatusBackgroundColor = Colors.red;
        checkinButton = blankContainer;
      }
    }

    checkCurrentRoomStatus();
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            color: currentStatusBackgroundColor,
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: MyRoomName(
                      '${DateFormat.Hms().format(DateTime.now())} | Sala 4A | Marvin'),
                ),
                Expanded(
                  flex: 7,
                  child: MyRoomStatus(currentStatusText),
                ),
                Expanded(
                  flex: 2,
                  child: checkinButton,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Container(
            color: Color.fromARGB(255, 240, 240, 240),
            child: MyScheduleCard(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return Scaffold(
      body: myLayoutWidget(),
    );
  }
}
