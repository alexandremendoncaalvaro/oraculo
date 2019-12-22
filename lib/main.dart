import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oraculo/my_room_occupation.dart';
import 'package:oraculo/my_schedule_card.dart';

void main() => runApp(MyApp());

ThemeData myTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    primaryColor: Colors.blue,
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
  Widget myLayoutWidget() {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            color: Colors.green,
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: MyRoomName('Sala 4A | Marvin'),
                ),
                Expanded(
                  flex: 7,
                  child: MyRoomStatus('LIVRE'),
                ),
                Expanded(
                  flex: 2,
                  child: MyRoomCheckinButton('fazer check-in'),
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

