
import 'dart:collection';
import 'package:intl/intl.dart';
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
  final DocumentReference conferenceRef;
  final UserCredential userCredential;
  final Role role;

  Schedule({Key key,
    @required this.conferenceRef,
    @required this.userCredential,
    @required this.role
  }) : super(key: key);

  @override
  _ScheduleState createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  static final DateFormat dateFormat = DateFormat('dd MMM, yyyy - HH:mm');
  static const TextStyle bold = TextStyle(fontWeight: FontWeight.bold);

  SplayTreeMap<Session, Event> _map;

  Widget _buildListItem(BuildContext context, int index) {
    final Session session = _map.keys.skip(index).first;
    final Event event = _map[session];

    List<InlineSpan> richText = [
      const TextSpan(text: 'From: ', style: bold),
      TextSpan(text: '${dateFormat.format(session.startDate)}\n'),
      const TextSpan(text: 'To: ', style: bold),
      TextSpan(text: '${dateFormat.format(session.endDate)}'),
    ];

    return ListTile(
      title: Text(event.name, style: bold),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(TextSpan(children: richText)),
        ],
      ),
    );
  }

  Widget _buildSchedule() {
    Widget body;

    if (_map.length == 0) {
      body = const Center(
        child: Text(
          'No schedule defined.',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold
          ),
        ),
      );
    }
    else {
      body = ListView.separated(
        itemBuilder: _buildListItem,
        separatorBuilder: (context, index) => const GenericSeparator(),
        itemCount: _map.length,
      );
    }

    return body;
  }

  Future<SplayTreeMap<Session, Event>> _getSchedule() {
    Future<QuerySnapshot> snapshot = widget.conferenceRef.collection('events').get();
    return snapshot.then((value) {
      SplayTreeMap<Session, Event> map = SplayTreeMap((a, b) => a.startDate.compareTo(b.startDate));

      for (DocumentSnapshot doc in value.docs) {
        Event event = Event.fromDatabaseFormat(doc.data());
        
        for (Session session in event.sessions) {
          if (session.assignedUsers.contains(widget.userCredential.user.uid)) {
            map[session] = event;
            break;
          }
        }
      }

      return map;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body = FutureBuilder<SplayTreeMap<Session, Event>>(
      future: _getSchedule(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _map = snapshot.data;
          return _buildSchedule();
        }
        else if (snapshot.hasError) {
          return const GenericErrorIndicator();
        }
        else {
          return const GenericLoadingIndicator();
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