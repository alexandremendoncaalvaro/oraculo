import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oraculo/appointment.dart';

class MyScheduleCard extends StatelessWidget {
  final Color textColor = Color.fromARGB(255, 110, 110, 110);

  @override
  Widget build(BuildContext context) {

    final schedule = Appointments(appointments).getSchedule();

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
            // color: Color.fromARGB(255, 200, 200, 200),
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

    if (startHour.difference(nowHour).inMinutes < 0) {
      startTime = nowHour;
    }
    return this.appointmentData.endTime.difference(startTime).inMinutes * 4.0;
  }

  int colorAlpha() {
    return appointmentData.subject != "Livre" ? 255 : 0;
  }

  List<BoxShadow> boxShadow() {
    return appointmentData.subject != "Livre"
        ? [BoxShadow(color: Color.fromARGB(50, 0, 0, 0), blurRadius: 2)]
        : null;
  }

  Color fontColor() {
    return appointmentData.subject != "Livre"
        ? Color.fromARGB(255, 150, 50, 50)
        : Color.fromARGB(255, 50, 150, 50);
  }

  Color backgroundColor() {
    var now = DateTime.now();
    return appointmentData.startTime.isBefore(now) & appointmentData.endTime.isAfter(now)
        ? Color.fromARGB(colorAlpha(), 255, 225, 225)
        : Color.fromARGB(colorAlpha(), 245, 245, 245);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: duration(),
      width: double.infinity,
      child: Container(
        margin: EdgeInsets.fromLTRB(5, 2, 0, 2),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: backgroundColor(),
          boxShadow: null, //boxShadow(),
        ),
        child: Text(
          '${DateFormat.Hm().format(this.appointmentData.startTime)} - ${DateFormat.Hm().format(this.appointmentData.endTime)} ${this.appointmentData.subject}',
          style: TextStyle(color: fontColor()),
        ),
      ),
    );
  }
}
