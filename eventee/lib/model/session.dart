
import 'dart:collection';
import 'package:flutter/foundation.dart';

class Session {
  DateTime startDate, endDate;
  String location; // May be changed after Google Places integration
  int attendanceLimit;
  LinkedHashSet<String> availabilities, assignedUsers;

  Session({
    @required this.startDate,
    @required this.endDate,
    @required this.location,
    this.attendanceLimit = 0,
    this.availabilities,
  }) {
    assignedUsers = LinkedHashSet();
  }

  Session.fromDatabaseFormat(Map<String, dynamic> map) {
    startDate = DateTime.fromMillisecondsSinceEpoch(map['start_date'].millisecondsSinceEpoch);
    endDate = DateTime.fromMillisecondsSinceEpoch(map['end_date'].millisecondsSinceEpoch);
    location = map['location'];
    attendanceLimit = map['attendance_limit'];
    availabilities = LinkedHashSet.from(map['availabilities']);
    assignedUsers = LinkedHashSet.from(map['assigned_users']);
  }

  Map<String, dynamic> toDatabaseFormat() {
    return {
      'start_date': startDate,
      'end_date': endDate,
      'location': location,
      'attendance_limit': attendanceLimit,
      'availabilities': availabilities.toList(),
      'assignedUsers': assignedUsers.toList(),
    };
  }
  
  bool isAttendanceLimited() => attendanceLimit > 0;
}