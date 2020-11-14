
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
}