import 'package:flutter/material.dart';
import 'package:oraculo/controllers/appointment_controller.dart';
import 'package:oraculo/models/appointment_model.dart';
import 'package:oraculo/helpers/time_helper.dart';
import 'package:intl/intl.dart';
import 'package:oraculo/themes.dart';

class RoomScheduleView extends StatefulWidget {
  RoomScheduleView({
    Key key,
    @required this.schedule,
    this.scrollCounter,
    this.resetScrollCounterCallback,
  }) : super(key: key);

  final List<AppointmentModel> schedule;
  final int scrollCounter;
  final Function resetScrollCounterCallback;
  static const PIXEl_HOUR_FACTOR = 6.0;
  static const TIMELINE_WIDTH = 90.0;

  @override
  _RoomScheduleViewState createState() => _RoomScheduleViewState();
}

class _RoomScheduleViewState extends State<RoomScheduleView> {
  final _theme = DefaultTheme();

  final _timeHelper = TimeHelper();

  final _scrollController = ScrollController();

  Container _buildAppointmentContainer(AppointmentModel appointment) {
    var _border = BorderSide.none;
    var _colorAlpha = 0;
    var _fontColor = Color.fromARGB(255, 50, 150, 50);

    void _getFreeRoomTheme() {
      if (appointment.subject != AppointmentController.FREE_ROOM_TEXT) {
        _border = BorderSide(width: 1.0, color: Color.fromARGB(30, 0, 0, 0));
        _colorAlpha = 255;
        _fontColor = Color.fromARGB(255, 150, 50, 50);
      }
    }

    _getFreeRoomTheme();

    double duration() {
      var _startTime = appointment.viewStartTime;
      var _startHour = DateTime(_startTime.year, _startTime.month,
          _startTime.day, _startTime.hour, 0);
      if (_startHour.difference(_timeHelper.nowHour).inMinutes < 0) {
        _startTime = _timeHelper.nowHour;
      }
      var _duration = appointment.viewEndTime.difference(_startTime).inMinutes *
          RoomScheduleView.PIXEl_HOUR_FACTOR;
      return _duration < 0.0 ? 0.0 : _duration;
    }

    Color _backgroundColor() =>
        appointment.startTime.isBefore(_timeHelper.now) &
                appointment.endTime.isAfter(_timeHelper.now)
            ? Color.fromARGB(_colorAlpha, 255, 225, 225)
            : Color.fromARGB(_colorAlpha, 245, 245, 245);

    String _buildContainerStatusText(AppointmentModel appointment) {
      var _statusText = '';
      if (appointment.subject == AppointmentController.FREE_ROOM_TEXT)
        return _statusText;

      switch (appointment.status) {
        case AppointmentStatus.CANCELLED:
          _statusText = 'CANCELADA';
          break;
        case AppointmentStatus.CHECKIN:
          _statusText = 'CHECK-IN';
          break;
        case AppointmentStatus.ENDED:
          _statusText = 'FINALIZADA';
          break;
        case AppointmentStatus.STARTED:
          _statusText = 'CHECK-IN OK!';
          break;
        case AppointmentStatus.UPCOMMING:
          _statusText = 'AGENDADA';
          break;
        default:
      }
      return '[$_statusText]';
    }

    return Container(
      height: duration(),
      margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
      padding: EdgeInsets.fromLTRB(5, 2, 5, 2),
      decoration: BoxDecoration(
        color: _backgroundColor(),
        border: Border(
            top: _border, bottom: _border, left: _border, right: _border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // appointment.status == AppointmentStatus.CHECKIN
          //     ? Icon(
          //         Icons.star,
          //         size: 15,
          //         color: _theme.primaryColorReadyToCheckinRoom,
          //       )
          //     : Container(),
          Text(
            '${DateFormat.Hm().format(appointment.startTime)}~${DateFormat.Hm().format(appointment.endTime)} ${appointment.subject}',
            style: TextStyle(color: _fontColor),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.topRight,
              child: Text(
                _buildContainerStatusText(appointment),
                style: TextStyle(
                  color: Colors.blueGrey,
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
                height: 60 * RoomScheduleView.PIXEl_HOUR_FACTOR,
                child: Container(
                  color: _theme.backgroundColorTimeline,
                  width: RoomScheduleView.TIMELINE_WIDTH,
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
    final _currenTimeToHeight =
        (_timeHelper.now.minute * RoomScheduleView.PIXEl_HOUR_FACTOR) +
            (_timeHelper.now.second / (60 / RoomScheduleView.PIXEl_HOUR_FACTOR))
                .floor();
    return Positioned(
      top: _currenTimeToHeight,
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(0),
            height: 24,
            width: RoomScheduleView.TIMELINE_WIDTH + 10,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.red,
                ),
              ),
            ),
            child: Container(
              color: _theme.backgroundColorTimeline,
              width: RoomScheduleView.TIMELINE_WIDTH,
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
    void _resetScrollWhenIdle() {
      if (_scrollController.hasClients) {
        final _position = _scrollController.position.pixels;

        if (widget.scrollCounter >= 10 && _position > 0.0) {
          _scrollController.animateTo(
            0.0,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 300),
          );
        }
      }
    }

    widget.schedule.asMap().forEach((k, a) {
      if (a.status == AppointmentStatus.CANCELLED) {
        a.viewEndTime =
            _timeHelper.fromDateTime(a.startTime.add(Duration(minutes: 5)));
        if (widget.schedule[k + 1].subject ==
            AppointmentController.FREE_ROOM_TEXT) {
          widget.schedule[k + 1].startTime =
              _timeHelper.fromDateTime(a.viewEndTime);
        }else{
          a.viewEndTime = _timeHelper.fromDateTime(widget.schedule[k + 1].startTime);
          //TODO: Substituir por Blank Cointainer
        }

        if (a.viewEndTime.isBefore(_timeHelper.nowHour)) {
          a.startTime = _timeHelper.fromDateTime(a.viewEndTime);
        }
      } else {
        a.viewEndTime = _timeHelper.fromDateTime(a.endTime);
      }
      a.viewStartTime = _timeHelper.fromDateTime(a.startTime);
    });

    _resetScrollWhenIdle();

    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
        Color.fromARGB(255, 230, 230, 230),
        Color.fromARGB(255, 245, 245, 255),
        Color.fromARGB(255, 230, 230, 230),
      ])),
      child: NotificationListener(
        onNotification: (t) {
          if (t is ScrollEndNotification) {
            widget.resetScrollCounterCallback();
          }
          return true;
        },
        child: ListView(
          controller: _scrollController,
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
                    children: _buildScheduleList(widget.schedule),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
