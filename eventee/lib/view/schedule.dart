
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

  @override
  _ScheduleState createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  List<Event> _events;
  List<Session> _sessions;

  void filterEvents(List<QueryDocumentSnapshot> snapshots) {
    // Filter the Events
    // Keep the ones where the user will be participating in a session
    this._events = [];
    this._sessions = [];

    for (QueryDocumentSnapshot eventSnapshot in snapshots) {
      final Event event = Event.fromDatabaseFormat(eventSnapshot.data());
      final numberOfSessions = event.getNumberOfSessions();
      for (int index = 0; index < numberOfSessions; index ++) {
        final session = event.getSession(index);
        if (session.assignedUsers.contains(widget.userCredential.user.uid)) {
          this._events.add(event);
          this._sessions.add(session);
        }
      }
    }

    // Order by Starting Date
  }

  Widget _buildListItem(BuildContext context, int index) {
    final Event event = _events[index];
    final Session session = _sessions[index];

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

    if (_events.length == 0) {
      body = Center(
        child: Text("No Schedule Defined."),
      );
    }
    else {
      body = ListView.separated(
        itemBuilder: _buildListItem,
        separatorBuilder: (context, index) => const GenericSeparator(),
        itemCount: _events.length,
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