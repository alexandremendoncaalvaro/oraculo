import 'package:flutter/material.dart';
import 'package:oraculo/controllers/appointment_controller.dart';
import 'package:oraculo/models/appointment_model.dart';
import 'package:oraculo/helpers/time_helper.dart';
import 'package:intl/intl.dart';
import 'package:oraculo/themes.dart';

class RoomScheduleView extends StatelessWidget {
  RoomScheduleView({
    Key key,
    @required List<AppointmentModel> schedule,
  })  : _schedule = schedule,
        super(key: key);

  final List<AppointmentModel> _schedule;
  final _theme = DefaultTheme();
  final _timeHelper = TimeHelper();

  static const PIXEl_HOUR_FACTOR = 6.0;
  static const TIMELINE_WIDTH = 90.0;

  Container _buildAppointmentContainer(AppointmentModel appointment) {
    double duration() {
      var startTime = appointment.startTime;
      var startHour = DateTime(
          startTime.year, startTime.month, startTime.day, startTime.hour, 0);
      if (startHour.difference(_timeHelper.nowHour).inMinutes < 0) {
        startTime = _timeHelper.nowHour;
      }
      return appointment.endTime.difference(startTime).inMinutes *
          PIXEl_HOUR_FACTOR;
    }

    var _border = BorderSide.none;
    var _colorAlpha = 0;
    var _fontColor = Color.fromARGB(255, 50, 150, 50);

    if (appointment.subject != AppointmentController.FREE_ROOM_TEXT) {
      _border = BorderSide(width: 1.0, color: Color.fromARGB(30, 0, 0, 0));
      _colorAlpha = 255;
      _fontColor = Color.fromARGB(255, 150, 50, 50);
    }

    Color _backgroundColor() =>
        appointment.startTime.isBefore(_timeHelper.now) &
                appointment.endTime.isAfter(_timeHelper.now)
            ? Color.fromARGB(_colorAlpha, 255, 225, 225)
            : Color.fromARGB(_colorAlpha, 245, 245, 245);

    return Container(
      height: duration(),
      margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
      padding: EdgeInsets.fromLTRB(5, 2, 0, 2),
      decoration: BoxDecoration(
        color: _backgroundColor(),
        border: Border(
            top: _border, bottom: _border, left: _border, right: _border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          appointment.status == AppointmentStatus.CHECKIN
              ? Icon(
                  Icons.star,
                  size: 15,
                  color: _theme.primaryColorReadyToCheckinRoom,
                )
              : Container(),
          Text(
            '${DateFormat.Hm().format(appointment.startTime)}~${DateFormat.Hm().format(appointment.endTime)} ${appointment.subject}',
            style: TextStyle(color: _fontColor),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.topRight,
              child: Text(
                '[${appointment.status.toString().substring(appointment.status.toString().indexOf('.') + 1)}]',
                style: TextStyle(
                  color: Colors.deepPurple,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Container> _buildScheduleList(List<AppointmentModel> schedule) {
    return List.generate(
      schedule.length,
      (index) => _buildAppointmentContainer(schedule[index]),
    );
  }

  _buildHourTimeLine() {
    return List.generate(24 - _timeHelper.now.hour, (index) {
      return Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                height: 60 * PIXEl_HOUR_FACTOR,
                child: Container(
                  color: _theme.backgroundColorTimeline,
                  width: TIMELINE_WIDTH,
                  margin: EdgeInsets.fromLTRB(5, 2, 5, 2),
                  padding: EdgeInsets.all(0),
                  alignment: Alignment.topCenter,
                  child: Text(
                    '${(DateTime.now().hour + index).toString().padLeft(2, '0')}:00',
                    style: TextStyle(color: Color.fromARGB(255, 200, 200, 200)),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  _buildFloatingBannerCurrentTime() {
    final _currenTimeToHeight = (_timeHelper.now.minute * PIXEl_HOUR_FACTOR) +
        (_timeHelper.now.second / (60 / PIXEl_HOUR_FACTOR)).floor();

    return Positioned(
      top: _currenTimeToHeight,
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(0),
            height: 24,
            width: TIMELINE_WIDTH + 10,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.red,
                ),
              ),
            ),
            child: Container(
              color: _theme.backgroundColorTimeline,
              width: TIMELINE_WIDTH,
              alignment: Alignment.center,
              child: Text(
                '${DateFormat.Hms().format(_timeHelper.now)}',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
        Color.fromARGB(255, 230, 230, 230),
        Color.fromARGB(255, 245, 245, 255),
        Color.fromARGB(255, 230, 230, 230),
      ])),
      child: ListView(
        padding: EdgeInsets.all(0),
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Column(
                    children: _buildHourTimeLine(),
                  ),
                  _buildFloatingBannerCurrentTime(),
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildScheduleList(_schedule),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
