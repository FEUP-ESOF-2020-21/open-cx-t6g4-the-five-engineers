

import 'package:eventee/scheduling_algorithm.dart';
import 'package:eventee/model/conference.dart';
import 'package:eventee/model/session.dart';
import 'package:eventee/model/event.dart';
import 'package:test/test.dart';

void main() {
  Conference conference = Conference(
    name: 'Conference',
    organizerUid: '1234',
    description: 'Description',
    startDate: DateTime.utc(2020, 12, 20),
    endDate: DateTime.utc(2020, 12, 23),
    location: 'Somewheresville',
    tags: [],
    events: [
      Event(
        name: 'Event 1',
        description: 'Description',
        tags: [],
        sessions: [
          Session(
            startDate: DateTime.utc(2020, 12, 20, 8, 30),
            endDate: DateTime.utc(2020, 12, 20, 10, 30),
            location: '',
            attendanceLimit: 2,
            availabilities: ['1', '2', '3'],
          ),
          Session(
            startDate: DateTime.utc(2020, 12, 20, 10, 30),
            endDate: DateTime.utc(2020, 12, 20, 12, 30),
            location: '',
            attendanceLimit: 2,
            availabilities: ['1', '2', '3', '4'],
          ),
          Session(
            startDate: DateTime.utc(2020, 12, 20, 12, 30),
            endDate: DateTime.utc(2020, 12, 20, 14, 30),
            location: '',
            attendanceLimit: 2,
            availabilities: ['1', '2'],
          ),
        ]
      ),
      Event(
        name: 'Event 2',
        description: 'Description',
        tags: [],
        sessions: [
          Session(
            startDate: DateTime.utc(2020, 12, 20, 7, 30),
            endDate: DateTime.utc(2020, 12, 20, 9, 30),
            location: '',
            attendanceLimit: 3,
            availabilities: ['1', '4', '5'],
          ),
          Session(
            startDate: DateTime.utc(2020, 12, 20, 9, 30),
            endDate: DateTime.utc(2020, 12, 20, 11, 30),
            location: '',
            attendanceLimit: 3,
            availabilities: ['3', '5'],
          ),
          Session(
            startDate: DateTime.utc(2020, 12, 20, 11, 30),
            endDate: DateTime.utc(2020, 12, 20, 13, 30),
            location: '',
            attendanceLimit: 3,
            availabilities: ['1', '5'],
          ),
        ]
      ),
    ]
  );

  test('Scheduling algorithm test', () {
    final result = generateSchedules(conference);

    for (MapEntry e in result.entries) {
      print(e.key.toString() + ' ---- ' + e.value.toString());
    }
  });

}
