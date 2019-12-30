class TimeHelper {
  int get dayHours => 24;
  DateTime get now => DateTime.now();
  DateTime get nowHour => DateTime(now.year, now.month, now.day, now.hour, 0);
  DateTime get todayAtCurrentHour => DateTime(now.year, now.month, now.day, now.hour);
  DateTime get todayStart => DateTime(now.year, now.month, now.day);
  DateTime get tomorowStart => todayStart.add(Duration(days: 1));
  DateTime get todayEnd => tomorowStart.subtract(Duration(seconds: 1));
  DateTime get yesterdayEnd => todayStart.subtract(Duration(seconds: 1));
}
