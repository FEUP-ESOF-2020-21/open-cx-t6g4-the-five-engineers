
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventee/model/conference.dart';
import 'package:eventee/model/event.dart';
import 'package:eventee/model/role.dart';
import 'package:eventee/model/session.dart';
import 'package:eventee/view/utils/generic_error_indicator.dart';
import 'package:eventee/view/utils/generic_loading_indicator.dart';
import 'package:eventee/view/utils/generic_separator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Schedule extends StatefulWidget {
  Schedule({Key key,
    @required this.conferenceRef,
    @required this.userCredential,
    @required this.role
  }) : super(key: key);

  final DocumentReference conferenceRef;
  final UserCredential userCredential;
  final Role role;

  final Conference conference = Conference(
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
                availabilities: LinkedHashSet.from(['1', '2', '3']),
              ),
              Session(
                startDate: DateTime.utc(2020, 12, 20, 10, 30),
                endDate: DateTime.utc(2020, 12, 20, 12, 30),
                location: '',
                attendanceLimit: 2,
                availabilities: LinkedHashSet.from(['1', '2', '3', '4']),
              ),
              Session(
                startDate: DateTime.utc(2020, 12, 20, 12, 30),
                endDate: DateTime.utc(2020, 12, 20, 14, 30),
                location: '',
                attendanceLimit: 2,
                availabilities: LinkedHashSet.from(['1', '2']),
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
                availabilities: LinkedHashSet.from(['1', '4', '5']),
              ),
              Session(
                startDate: DateTime.utc(2020, 12, 20, 9, 30),
                endDate: DateTime.utc(2020, 12, 20, 11, 30),
                location: '',
                attendanceLimit: 3,
                availabilities: LinkedHashSet.from(['3', '5']),
              ),
              Session(
                startDate: DateTime.utc(2020, 12, 20, 11, 30),
                endDate: DateTime.utc(2020, 12, 20, 13, 30),
                location: '',
                attendanceLimit: 3,
                availabilities: LinkedHashSet.from(['1', '5']),
              ),
            ]
        ),
      ]
  );

  @override
  _ScheduleState createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  List<QueryDocumentSnapshot> _eventSnapshots;
  List<int> _sessions;

  void filterEvents(List<QueryDocumentSnapshot> events) {
    // Filter the Events
    // Keep the ones where the user will be participating in a session
    this._eventSnapshots = [];
    this._sessions = [];

    for (QueryDocumentSnapshot event in events) {
      //
    }

    // Order by Starting Date
  }

  Widget _buildListItem(BuildContext context, int index) {
    final QueryDocumentSnapshot eventSnapshot = _eventSnapshots[index];
    final Event event = Event.fromDatabaseFormat(eventSnapshot.data());
    final Session session = event.getSession(_sessions[index]);

    return ListTile(
      title: Text(event.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            session.startDate.toString() + ' - ' + session.endDate.toString(),
          ),
          Text(
            'Location: ' + session.location,
          )
        ],
      ),
    );
  }

  Widget _buildEvent(AsyncSnapshot<QuerySnapshot> eventSnapshot) {
    Widget body;
    filterEvents(eventSnapshot.data.docs);

    if (_eventSnapshots.length == 0) {
      body = Center(
        child: Text("No Schedule Defined."),
      );
    }
    else {
      body = ListView.separated(
        itemBuilder: _buildListItem,
        separatorBuilder: (context, index) => const GenericSeparator(),
        itemCount: _eventSnapshots.length,
      );
    }
    return body;
  }

  @override
  Widget build(BuildContext context) {
    Widget body = StreamBuilder<QuerySnapshot> (
      stream: widget.conferenceRef.collection('events').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.size != 0) {
            return _buildEvent(snapshot);
          }
          else {
            return const Center(
              child: Text("No Schedule Defined."),
            );
          }
        }
        else if (snapshot.hasError) {
          return const GenericErrorIndicator();
        }
        else {
          return Center(
            child: const CircularProgressIndicator(),
          );
        }
      }
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Schedule'),
      ),
      body: body,
    );
  }
}