enum AppointmentStatus { 
   UPCOMMING,
   CHECKIN,
   STARTED, 
   ENDED, 
   CANCELLED 
} 

class AppointmentModel {
  DateTime startTime;
  DateTime endTime;
  String subject;
  AppointmentStatus status;
  AppointmentModel({this.startTime, this.endTime, this.subject, this.status = AppointmentStatus.UPCOMMING});
}