
import 'package:flutter/foundation.dart';

class Session {
  DateTime startDate, endDate;
  String location; // May be changed after Google Places integration
  int attendanceLimit;

  Session({
    @required this.startDate,
    @required this.endDate,
    @required this.location,
    this.attendanceLimit = 0
  });

  Session.fromDatabaseFormat(Map<String, dynamic> map) {
    startDate = DateTime.fromMillisecondsSinceEpoch(map['start_date'].millisecondsSinceEpoch);
    endDate = DateTime.fromMillisecondsSinceEpoch(map['end_date'].millisecondsSinceEpoch);
    location = map['location'];
    attendanceLimit = map['attendance_limit'];
  }

  Map<String, dynamic> toDatabaseFormat() {
    return {
      'start_date': startDate,
      'end_date': endDate,
      'location': location,
      'attendance_limit': attendanceLimit,
    };
  }
  
  bool isAttendanceLimited() => attendanceLimit > 0;
}