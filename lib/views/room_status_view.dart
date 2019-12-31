import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oraculo/controllers/appointment_controller.dart';
import 'package:oraculo/models/appointment_model.dart';
import 'package:oraculo/helpers/time_helper.dart';
import 'package:oraculo/themes.dart';

class RoomStatusView extends StatelessWidget {
  final _schedule;

  RoomStatusView({
    Key key,
    @required List<AppointmentModel> schedule,
  })  : _schedule = schedule,
        super(key: key);

  static const TEXT_MEETING_CANCELLED =
      'Reunião atual cancelada por não comparecimento\nSala livre para novos agendamentos';

  static const TEXT_MEETING_STARTED = 'check-in(s) confirmado(s)!';

  static const TEXT_FREE_ROOM =
      'Pode usar a sala, mas fica esperto\nse alguém agendar agora a reserva é dele.';

  final _timeHelper = TimeHelper();
  final _theme = DefaultTheme();

  AppointmentModel _getReadyToCheckinAppointment(
      List<AppointmentModel> schedule) {
    return schedule.firstWhere((a) => a.status == AppointmentStatus.CHECKIN,
        orElse: () => null);
  }

  AppointmentModel _getStartedAppointment(List<AppointmentModel> schedule) {
    return schedule.firstWhere((a) => a.status == AppointmentStatus.STARTED,
        orElse: () => null);
  }

  AppointmentModel _getCancelledAppointment(List<AppointmentModel> schedule) {
    return schedule.firstWhere((a) => a.status == AppointmentStatus.CANCELLED,
        orElse: () => null);
  }

  AppointmentStatus _getCurrentRoomStatus(
      List<AppointmentModel> schedule,
      AppointmentModel startedAppointment,
      AppointmentModel readyToCheckinAppointment) {
    if (startedAppointment?.status == AppointmentStatus.STARTED)
      return AppointmentStatus.STARTED;
    if (readyToCheckinAppointment?.status == AppointmentStatus.CHECKIN)
      return AppointmentStatus.CHECKIN;

    final _currentAppointment = schedule.firstWhere(
        (a) =>
            (a.subject != AppointmentController.FREE_ROOM_TEXT) &&
            a.startTime
                .subtract(Duration(
                    minutes: AppointmentController.MINUTES_TO_RELEASE_CHECKIN))
                .isBefore(_timeHelper.now) &&
            a.endTime.isAfter(_timeHelper.now),
        orElse: () => null);
    if (_currentAppointment == null) return AppointmentStatus.UPCOMMING;
    return _currentAppointment.status;
  }

  Color _getBackgroundStatusColor(AppointmentStatus _currentRoomStatus) {
    if (_currentRoomStatus == AppointmentStatus.UPCOMMING)
      return _theme.primaryColorFreeRoom;
    if (_currentRoomStatus == AppointmentStatus.ENDED)
      return _theme.primaryColorFreeRoom;
    if (_currentRoomStatus == AppointmentStatus.STARTED)
      return _theme.primaryColorBusyRoom;
    if (_currentRoomStatus == AppointmentStatus.CHECKIN)
      return _theme.primaryColorReadyToCheckinRoom;
    if (_currentRoomStatus == AppointmentStatus.CANCELLED)
      return _theme.primaryColorCancelledRoom;
    return _theme.primaryColorFreeRoom;
  }

  List<Widget> _buildStatusTextWidget(
      {AppointmentStatus currentRoomStatus,
      AppointmentModel readyToCheckinAppointment,
      AppointmentModel startedAppointment,
      AppointmentModel cancelledAppointment}) {
    var _statusText = '';
    var _subText = '';
    if (currentRoomStatus == AppointmentStatus.UPCOMMING)
      _statusText = AppointmentController.FREE_ROOM_TEXT;
    if (currentRoomStatus == AppointmentStatus.ENDED)
      _statusText = AppointmentController.FREE_ROOM_TEXT;
    if (currentRoomStatus == AppointmentStatus.STARTED) {
      _statusText = AppointmentController.BUSY_ROOM_TEXT;
      _subText = startedAppointment?.subject;
    }
    if (currentRoomStatus == AppointmentStatus.CHECKIN) {
      _statusText = AppointmentController.SOON_MEETING_ROOM_TEXT;
      _subText = readyToCheckinAppointment?.subject;
    }
    if (currentRoomStatus == AppointmentStatus.CANCELLED) {
      _statusText = AppointmentController.FREE_ROOM_TEXT;
      _subText = '${DateFormat.Hm().format(cancelledAppointment?.startTime)}~${DateFormat.Hm().format(cancelledAppointment?.endTime)} ${cancelledAppointment?.subject}';
    }

    return [
      Text(
        _statusText,
        style: TextStyle(
          fontSize: 90,
          fontWeight: FontWeight.w700,
        ),
      ),
      Text(
        _subText,
        style: TextStyle(
          fontSize: 26,
          decoration: currentRoomStatus == AppointmentStatus.CANCELLED
              ? TextDecoration.lineThrough
              : TextDecoration.none,
        ),
      ),
    ];
  }

  String _getButtonCheckinText(AppointmentModel readyToCheckinAppointment) {
    var _remainingTime = readyToCheckinAppointment?.startTime
        ?.add(Duration(minutes: 5))
        ?.difference(_timeHelper.now);
    return 'check-in (${_remainingTime?.inMinutes?.remainder(60).toString().padLeft(2, '0')}:${_remainingTime?.inSeconds?.remainder(60).toString().padLeft(2, '0')})';
  }

  _buildStatusBottomWidget(
      {AppointmentStatus currentRoomStatus,
      AppointmentModel startedAppointment,
      AppointmentModel readyToCheckinAppointment,
      AppointmentModel cancelledAppointment}) {

    if (readyToCheckinAppointment?.status == AppointmentStatus.CHECKIN) {
      return Padding(
        padding: const EdgeInsets.all(15.0),
        child: FractionallySizedBox(
          widthFactor: 1,
          child: FlatButton(
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(20.0),
              side: BorderSide(
                width: 2,
                color: Colors.white,
              ),
            ),
            color: Colors.blue[600],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  _getButtonCheckinText(readyToCheckinAppointment),
                  style: TextStyle(
                    fontSize: 36,
                  ),
                ),
                Text(
                  readyToCheckinAppointment?.subject,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            onPressed: () {
              readyToCheckinAppointment.status = AppointmentStatus.STARTED;
            },
          ),
        ),
      );
    }

    if (startedAppointment?.status == AppointmentStatus.STARTED) {
      return Container(
        color: Colors.red,
        alignment: Alignment.center,
        child: Text(
          TEXT_MEETING_STARTED,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
          ),
        ),
      );
    }

    if (cancelledAppointment != null) {
      if (_timeHelper.now.isBefore(cancelledAppointment.endTime) &&
          cancelledAppointment.status == AppointmentStatus.CANCELLED) {
        return Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: Text(
            TEXT_MEETING_CANCELLED,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
            ),
          ),
        );
      }
    }
    return Container(
      alignment: Alignment.center,
      child: Text(
        TEXT_FREE_ROOM,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 26,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppointmentModel _readyToCheckinAppointment =
        _getReadyToCheckinAppointment(_schedule);

    AppointmentModel _startedAppointment = _getStartedAppointment(_schedule);

    AppointmentModel _cancelledAppointment =
        _getCancelledAppointment(_schedule);

    AppointmentStatus _currentRoomStatus = _getCurrentRoomStatus(
        _schedule, _startedAppointment, _readyToCheckinAppointment);

    return Container(
      color: _getBackgroundStatusColor(_currentRoomStatus),
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '${DateFormat.Hms().format(_timeHelper.now)} | Sala 4A | Marvin',
                  style: TextStyle(
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildStatusTextWidget(
                      currentRoomStatus: _currentRoomStatus,
                      readyToCheckinAppointment: _readyToCheckinAppointment,
                      startedAppointment: _startedAppointment,
                      cancelledAppointment: _cancelledAppointment)),
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildStatusBottomWidget(
                currentRoomStatus: _currentRoomStatus,
                startedAppointment: _startedAppointment,
                readyToCheckinAppointment: _readyToCheckinAppointment,
                cancelledAppointment: _cancelledAppointment),
          ),
        ],
      ),
    );
  }
}
