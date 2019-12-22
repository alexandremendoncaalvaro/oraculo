import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentData {
  DateTime startTime;
  DateTime endTime;
  String subject;
  AppointmentData({this.startTime, this.endTime, this.subject});
}

final appointments = [
  AppointmentData(
    startTime: DateTime(2019, 12, 22, 00, 15),
    endTime: DateTime(2019, 12, 22, 02, 10),
    subject: 'Alexandre Alvaro Fandangueira',
  ),
  AppointmentData(
    startTime: DateTime(2019, 12, 22, 09, 00),
    endTime: DateTime(2019, 12, 22, 10, 00),
    subject: 'Estranho fazendo estranhezas',
  ),
  AppointmentData(
    startTime: DateTime(2019, 12, 22, 14, 00),
    endTime: DateTime(2019, 12, 22, 15, 50),
    subject: 'Pepe Moreno Desmontar ventilador',
  )
];

class MyScheduleCard extends StatelessWidget {
  final Color textColor = Color.fromARGB(255, 110, 110, 110);

  @override
  Widget build(BuildContext context) {
    final yesterdayEnd = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day - 1, 23, 59);

    final tomorowStart = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day + 1, 0, 0);

    final todayFromNowAppointments = appointments
        .where((a) =>
            (a.endTime.hour >= DateTime.now().hour) &
            a.endTime.isBefore(tomorowStart) &
            a.endTime.isAfter(yesterdayEnd))
        .toList();

    var schedule = [];
    for (var i = 0; i < todayFromNowAppointments.length; i++) {
      var blankAppointment = AppointmentData(subject: "Livre");
      final currentHour = DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, DateTime.now().hour, 0);
      if (i == 0) {
        if (todayFromNowAppointments[0]
                .startTime
                .difference(DateTime.now())
                .inMinutes >
            0) {
          blankAppointment.startTime = currentHour;
          blankAppointment.endTime = todayFromNowAppointments[i].startTime;
          schedule.add(blankAppointment);
        }
      } else {
        print(todayFromNowAppointments[i]
            .startTime
            .difference(todayFromNowAppointments[i - 1].endTime)
            .inMinutes);
        if (todayFromNowAppointments[i]
                .startTime
                .difference(todayFromNowAppointments[i - 1].endTime)
                .inMinutes >
            0) {
          blankAppointment.startTime = todayFromNowAppointments[i - 1].endTime;
          blankAppointment.endTime = todayFromNowAppointments[i].startTime;
          schedule.add(blankAppointment);
        }
      }
      schedule.add(todayFromNowAppointments[i]);
      if (i == todayFromNowAppointments.length - 1) {
        if (tomorowStart
                .difference(todayFromNowAppointments[i].endTime)
                .inMinutes >
            1) {
          var lastBlankAppointment = AppointmentData(
            subject: "Livre",
            startTime: todayFromNowAppointments[i].endTime,
            endTime: tomorowStart.subtract(Duration(minutes: 1)),
          );
          schedule.add(lastBlankAppointment);
        }
      }
    }

    return Column(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Container(
            alignment: Alignment.center,
            child: Text(
              'Próximas reuniões:',
              style: TextStyle(
                fontSize: 22,
                color: textColor,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 9,
          child: Container(
            // color: Colors.red,
            child: ListView(
              padding: EdgeInsets.all(0),
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      children:
                          List.generate(24 - DateTime.now().hour, (index) {
                        return Row(
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                HourTimeline(
                                  '${(DateTime.now().hour + index).toString().padLeft(2, '0')}:00',
                                )
                              ],
                            ),
                          ],
                        );
                      }),
                    ),
                    Expanded(
                      child: Container(
                        // color: Colors.red,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(schedule.length, (index) {
                            return AppointmentContainer(
                                appointmentData: schedule[index]);
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class HourTimeline extends StatelessWidget {
  final String hour;
  HourTimeline(this.hour);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      child: Container(
        color: Color.fromARGB(255, 245, 245, 245),
        width: 90,
        margin: EdgeInsets.fromLTRB(5, 2, 0, 2),
        padding: EdgeInsets.all(10),
        alignment: Alignment.center,
        child: Text(
          this.hour,
          style: TextStyle(color: Color.fromARGB(255, 150, 150, 150)),
        ),
      ),
    );
  }
}

class AppointmentContainer extends StatelessWidget {
  final AppointmentData appointmentData;
  AppointmentContainer({this.appointmentData});

  double duration() {
    var startTime = this.appointmentData.startTime;

    var startHour = DateTime(
        startTime.year, startTime.month, startTime.day, startTime.hour, 0);

    var nowHour = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, DateTime.now().hour, 0);

    // print(startHour.difference(nowHour).inMinutes);
    if (startHour.difference(nowHour).inMinutes < 0) {
      startTime = nowHour;
    }
    return this.appointmentData.endTime.difference(startTime).inMinutes * 4.0;
  }

  int colorAlpha() {
    return appointmentData.subject != "Livre" ? 255 : 0;
  }

  Color fontColor() {
    return appointmentData.subject != "Livre"
        ? Color.fromARGB(255, 150, 50, 50)
        : Color.fromARGB(255, 50, 150, 50);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: duration(),
      width: double.infinity,
      child: Container(
        color: Color.fromARGB(colorAlpha(), 245, 245, 245),
        margin: EdgeInsets.fromLTRB(5, 2, 0, 2),
        padding: EdgeInsets.all(10),
        // alignment: Alignment.center,
        child: Text(
          '${DateFormat.Hm().format(this.appointmentData.startTime)} - ${DateFormat.Hm().format(this.appointmentData.endTime)} ${this.appointmentData.subject}',
          style: TextStyle(color: fontColor()),
        ),
      ),
    );
  }
}
