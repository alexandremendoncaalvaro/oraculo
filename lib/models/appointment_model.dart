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
  DateTime viewStartTime;
  DateTime viewEndTime;
  String subject;
  AppointmentStatus status;
  AppointmentModel({this.startTime, this.endTime, this.viewStartTime, this.viewEndTime, this.subject, this.status = AppointmentStatus.UPCOMMING});
}