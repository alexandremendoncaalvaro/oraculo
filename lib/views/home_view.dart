import 'dart:async';

import 'package:flutter/material.dart';
import 'package:oraculo/views/room_schedule_view.dart';
import 'package:provider/provider.dart';

import 'package:oraculo/controllers/appointment_controller.dart';
import 'package:oraculo/system.dart';
import 'package:oraculo/views/room_status_view.dart';

class HomeView extends StatefulWidget {
  HomeView({Key key}) : super(key: key);
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Timer _timerRenderClock;

  @override
  initState() {
    super.initState();
    _timerRenderClock =
        Timer.periodic(Duration(seconds: 1), (_) => _renderClock());
  }

  void _renderClock() {
    setState(() {});
  }

  @override
  dispose() {
    super.dispose();
    _timerRenderClock.cancel();
  }

  @override
  Widget build(BuildContext context) {
    System().setDeviceConfig();
    return Scaffold(
      body: Consumer<AppointmentController>(
        builder: (context, appointmentController, widget) {
          final _schedule = appointmentController.schedule;
          return Row(
            children: [
              Expanded(
                flex: 5,
                child: RoomStatusView(schedule: _schedule),
              ),
              Expanded(
                flex: 5,
                child: RoomScheduleView(schedule: _schedule),
              ),
            ],
          );
        },
      ),
    );
  }
}

