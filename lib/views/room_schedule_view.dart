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
    // var _border = BorderSide.none;
    var _colorAlpha = 0.0;
    var _fontColor = Color.fromARGB(255, 50, 150, 50);

    void _getNonFreeRoomTheme() {
      if (appointment.subject != AppointmentController.FREE_ROOM_TEXT) {
        // _border = BorderSide(width: 1.0, color: Color.fromARGB(30, 0, 0, 0));
        _colorAlpha = 1.0;
        _fontColor = Colors.blue;
      }
    }

    _getNonFreeRoomTheme();

    double duration() {
      var _viewStartTime = appointment.viewStartTime;
      var _viewStartHour = DateTime(_viewStartTime.year, _viewStartTime.month,
          _viewStartTime.day, _viewStartTime.hour, 0);
      if (_viewStartHour.difference(_timeHelper.nowHour).inMinutes < 0) {
        _viewStartTime = _timeHelper.nowHour;
      }
      var _duration =
          appointment.viewEndTime.difference(_viewStartTime).inMinutes *
              RoomScheduleView.PIXEl_HOUR_FACTOR;
      return _duration < 0.0 ? 0.0 : _duration;
    }

    Color _backgroundColor() {
      if (appointment.status == AppointmentStatus.CHECKIN) {
        _fontColor = Colors.white;
        return Colors.blue[600];
      }
      if (appointment.startTime.isBefore(_timeHelper.now) &&
          appointment.endTime.isAfter(_timeHelper.now) &&
          appointment.subject != AppointmentController.FREE_ROOM_TEXT) {
        _fontColor = Colors.white;
        return Colors.red.withOpacity(_colorAlpha);
      }
      return Colors.white.withOpacity(_colorAlpha);
    }

    String _buildContainerStatusText(AppointmentModel appointment) {
      var _statusText = '';
      if (appointment.subject == AppointmentController.FREE_ROOM_TEXT)
        return _statusText;

      switch (appointment.status) {
        case AppointmentStatus.CANCELLED:
          _fontColor = Colors.red;
          _statusText = 'CANCELADA';
          break;
        case AppointmentStatus.CHECKIN:
          _fontColor = Colors.white;
          _statusText = 'CHECK-IN';
          break;
        case AppointmentStatus.ENDED:
          _fontColor = Colors.blue;
          _statusText = 'FINALIZADA';
          break;
        case AppointmentStatus.STARTED:
          _fontColor = Colors.blue;
          _statusText = 'CHECK-IN OK!';
          break;
        case AppointmentStatus.UPCOMMING:
          _fontColor = Colors.blue;
          _statusText = 'AGENDADA';
          break;
        default:
      }
      if (appointment.startTime.isBefore(_timeHelper.now) &&
          appointment.endTime.isAfter(_timeHelper.now)) {
        _fontColor = Colors.white;
      }
      return '[$_statusText]';
    }

    return Container(
      height: duration(),
      margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
      padding: EdgeInsets.fromLTRB(5, 2, 5, 2),
      decoration: BoxDecoration(
        color: _backgroundColor(),
        // border: Border(
        //     top: _border, bottom: _border, left: _border, right: _border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${DateFormat.Hm().format(appointment.startTime)}~${DateFormat.Hm().format(appointment.endTime)}',
                style: TextStyle(
                  color: _fontColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${appointment.subject}',
                style: TextStyle(
                  color: _fontColor,
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              alignment: Alignment.topRight,
              child: Text(
                _buildContainerStatusText(appointment),
                style: TextStyle(
                  color: _fontColor,
                  fontWeight: FontWeight.w700,
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
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  void _buildScheduleForView() {
    widget.schedule.asMap().forEach((k, a) {
      if (a.viewStartTime == null) {
        a.viewStartTime = _timeHelper.fromDateTime(a.startTime);
      }
      if (a.status == AppointmentStatus.CANCELLED) {
        a.viewEndTime =
            _timeHelper.fromDateTime(a.startTime.add(Duration(minutes: 5)));

        if (widget.schedule[k + 1].subject ==
            AppointmentController.FREE_ROOM_TEXT) {
          widget.schedule[k + 1].viewStartTime =
              _timeHelper.fromDateTime(a.viewEndTime);
        } else {
          a.viewEndTime =
              _timeHelper.fromDateTime(widget.schedule[k + 1].startTime);
        }

        if (a.viewEndTime.isBefore(_timeHelper.nowHour)) {
          a.viewStartTime = _timeHelper.fromDateTime(a.viewEndTime);
        }
      } else {
        a.viewEndTime = _timeHelper.fromDateTime(a.endTime);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _buildScheduleForView();
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
