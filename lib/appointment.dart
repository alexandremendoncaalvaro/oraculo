class AppointmentData {
  DateTime startTime;
  DateTime endTime;
  String subject;
  AppointmentData({this.startTime, this.endTime, this.subject});
}

class Appointments {
  final List<AppointmentData> appointments;
  Appointments(this.appointments);

  List getSchedule() {
    var schedule = [];

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
    return schedule;
  }
}
