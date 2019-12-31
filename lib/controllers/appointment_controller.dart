import 'package:oraculo/helpers/time_helper.dart';
import '../models/appointment_model.dart';

class AppointmentController {
  static const MINUTES_TO_RELEASE_CHECKIN = 15;
  static const FREE_ROOM_TEXT = 'LIVRE';
  static const BUSY_ROOM_TEXT = 'OCUPADA';
  static const SOON_MEETING_ROOM_TEXT = 'EM BREVE';
  final _timeHelper = TimeHelper();

  List<AppointmentModel> _appointments = [
    AppointmentModel(
      startTime: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, 10, 30),
      endTime: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, 11, 30),
      subject: 'Alexandre Alvaro Desenvolvimento Oraculo',
    ),
    AppointmentModel(
      startTime: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, 15, 23),
      endTime: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, 16, 20),
      subject: 'Estranho fazendo estranhezas',
    ),
    AppointmentModel(
      startTime: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, 18, 00),
      endTime: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, 19, 20),
      subject: 'Agente 007 Sem tempo irmão',
    ),
    AppointmentModel(
      startTime: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, 23, 30),
      endTime: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, 23, 40),
      subject: 'Man Bugar o shape!',
    ),
    AppointmentModel(
      startTime: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, 23, 50),
      endTime: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, 23, 59),
      subject: 'Noel Preparação para o Natal',
    ),
  ];

  List<AppointmentModel> get schedule {
    List<AppointmentModel> _schedule = [];

    var _firstCheckinReadyRoomMarked = false;

    final List<AppointmentModel> _todayFromNowAppointments =
        _appointments.where((a) {
      if ((a.subject != FREE_ROOM_TEXT) &&
          a.startTime
              .subtract(Duration(minutes: MINUTES_TO_RELEASE_CHECKIN))
              .isBefore(_timeHelper.now) &&
          a.endTime.isAfter(_timeHelper.now)) {
        if (!_firstCheckinReadyRoomMarked &&
            a.status == AppointmentStatus.UPCOMMING) {
          a.status = AppointmentStatus.CHECKIN;
          _firstCheckinReadyRoomMarked = true;
        }
      }

      return (a.endTime.hour >= _timeHelper.now.hour) &&
          a.endTime.isBefore(_timeHelper.tomorowStart) &&
          a.endTime.isAfter(_timeHelper.yesterdayEnd);
    }).toList();

    _getBlankAppointment(startTime, endTime) {
      return AppointmentModel(
          subject: FREE_ROOM_TEXT, startTime: startTime, endTime: endTime);
    }

    List<AppointmentModel> _finishExpiredAppointments(
        List<AppointmentModel> schedule) {
      schedule.forEach((a) {
        if ((a.status == AppointmentStatus.STARTED ||
                a.status == AppointmentStatus.UPCOMMING ||
                a.subject == FREE_ROOM_TEXT) &&
            _timeHelper.now.isAfter(a.endTime)) {
          a.status = AppointmentStatus.ENDED;
        }
        if (a.status == AppointmentStatus.CHECKIN &&
            _timeHelper.now.isAfter(a.startTime.add(Duration(minutes: 5)))) {
          a.status = AppointmentStatus.CANCELLED;
        }
      });
      return schedule;
    }

    final isThereNoMoreAppointments = _todayFromNowAppointments.length == 0;

    if (isThereNoMoreAppointments) {
      _schedule.add(_getBlankAppointment(
          _timeHelper.todayAtCurrentHour, _timeHelper.todayEnd));
    } else {
      for (var i = 0; i < _todayFromNowAppointments.length; i++) {
        AppointmentModel _appointment;

        if (i == 0) {
          final _isItStartAtCurrentHour =
              _todayFromNowAppointments[i].startTime.hour ==
                  _timeHelper.now.hour;
          final _isItStartsBiggerThanOneMinuteFromCurrentHour =
              _todayFromNowAppointments[i]
                      .startTime
                      .difference(_timeHelper.now)
                      .inMinutes >
                  0;

          if (_isItStartAtCurrentHour ||
              _isItStartsBiggerThanOneMinuteFromCurrentHour) {
            _appointment = _getBlankAppointment(_timeHelper.todayAtCurrentHour,
                _todayFromNowAppointments[i].startTime);
            _schedule.add(_appointment);
          }
        } else {
          final _isTimeBetweenLastOneAndThisBiggerThanOneMinute =
              _todayFromNowAppointments[i]
                      .startTime
                      .difference(_todayFromNowAppointments[i - 1].endTime)
                      .inMinutes >
                  0;
          if (_isTimeBetweenLastOneAndThisBiggerThanOneMinute) {
            _appointment = _getBlankAppointment(
                _todayFromNowAppointments[i - 1].endTime,
                _todayFromNowAppointments[i].startTime);
          } else {
            _appointment = _getBlankAppointment(
                _todayFromNowAppointments[i - 1].endTime,
                _todayFromNowAppointments[i - 1].endTime);
          }
          _schedule.add(_appointment);
        }
        _schedule.add(_todayFromNowAppointments[i]);
      }

      final _lastAppointment = _schedule.last;

      final hasAFreeTimeAfterCurrentAppointment = _timeHelper.tomorowStart
              .difference(_lastAppointment.endTime)
              .inMinutes >
          1;
      if (hasAFreeTimeAfterCurrentAppointment) {
        _schedule.add(_getBlankAppointment(
            _lastAppointment.endTime, _timeHelper.todayEnd));
      }
    }

    _schedule = _finishExpiredAppointments(_schedule);

    return _schedule;
  }
}
