
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:eventee/model/session.dart';
import 'package:eventee/model/event.dart';
import 'package:eventee/model/conference.dart';

class SchedulingAvailability {
  String uid;
  Event event;
  Session session;

  SchedulingAvailability({
    @required this.uid,
    @required this.event,
    @required this.session,
  });
}

Map<String, List<SchedulingAvailability>> getUserAvailabilityMap(Conference conference) {
  Map<String, List<SchedulingAvailability>> map = {};

  for (Event event in conference.events) {
    for (Session session in event.sessions) {
      for (String uid in session.availabilities) {
        if (map[uid] == null) {
          map[uid] = [SchedulingAvailability(uid: uid, event: event, session: session)];
        }
        else {
          map[uid].add(SchedulingAvailability(uid: uid, event: event, session: session));
        }
      }
    }
  }

  return map;
}

Map<String, Map<Event, Session>> generateSchedules(Conference conference) {
  final rng = new Random();
  final map = getUserAvailabilityMap(conference);

  Map<String, Map<Event, Session>> assignedSessions = {};

  while (map.isNotEmpty) {
    String uid = map.keys.elementAt(rng.nextInt(map.keys.length));
    assignedSessions[uid] = {};

    map[uid].sort((a, b) => a.session.endDate.compareTo(b.session.endDate));

    for (SchedulingAvailability sch in map[uid]) {
      if (assignedSessions[uid][sch.event] == null) {
        bool sessionCollides = false;

        for (Session other in assignedSessions[uid].values) {
          if (other.endDate.isAfter(sch.session.startDate)) {
            sessionCollides = true;
            break;
          }
        }

        if (sessionCollides) {
          sch.session.availabilities.remove(sch.uid);
          continue;
        }

        if (sch.session.isAttendanceLimited()) {
          int position = sch.session.availabilities.toList().indexOf(sch.uid);
      
          if (position < sch.session.attendanceLimit) {
            assignedSessions[uid][sch.event] = sch.session;
          }
        }
      }
      else {
        sch.session.availabilities.remove(sch.uid);
      }
    }

    map.remove(uid);
  }

  return assignedSessions;
}
