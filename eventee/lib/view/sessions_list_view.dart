
import 'package:eventee/model/session.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventee/model/event.dart';
import 'package:eventee/view/create_session.dart';
import 'package:eventee/view/utils/generic_error_indicator.dart';
import 'package:eventee/view/utils/generic_loading_indicator.dart';
import 'package:eventee/view/utils/generic_separator.dart';

class SessionsListView extends StatefulWidget {
  final DocumentReference conferenceRef, eventRef;

  SessionsListView({Key key, this.conferenceRef, this.eventRef}) : super(key: key);

  @override
  _SessionsListViewState createState() => _SessionsListViewState();
}

class _SessionsListViewState extends State<SessionsListView> {
  Event _event;

  Widget _buildListItem(BuildContext context, int index) {
    Session session = _event.sessions[index];
    
    // TODO: Replace with proper date formatting
    const TextStyle bold = TextStyle(fontWeight: FontWeight.bold);

    List<InlineSpan> richText = [
      const TextSpan(text: 'From: ', style: bold),
      TextSpan(text: '${session.startDate.toString().substring(0, 16)}\n'),
      const TextSpan(text: 'To: ', style: bold),
      TextSpan(text: '${session.endDate.toString().substring(0, 16)}\n'),
    ];

    if (session.isAttendanceLimited()) {
      richText.addAll([
        const TextSpan(text: 'Attendance limited to '),
        TextSpan(text: '${session.attendanceLimit}', style: bold),
        const TextSpan(text: ' people'),
      ]);
    }

    return ListTile(
      subtitle: Text.rich(TextSpan(children: richText)),
      title: Text('Session ${index + 1}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {}, // TODO
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {}, // TODO
          ),
        ],
      ),
    );
  }

  @override
  Widget build(context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: widget.eventRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _event = Event.fromDatabaseFormat(snapshot.data.data());

          return Column(
            children: [
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        'Sessions',
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    true ? IconButton( // TODO: replace with organizer check
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CreateSession())
                        );
                      },
                    ) : null,
                  ],
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[200],
                  border: Border.all(
                    color: Colors.blueAccent,
                    width: 3.0,
                  ),
                ),
              ),
              ListView.separated(
                itemCount: snapshot.data['sessions'].length,
                itemBuilder: _buildListItem,
                separatorBuilder: (context, index) => const GenericSeparator(),
                shrinkWrap: true,
              ),
            ],
          );
        }
        else if (snapshot.hasError) {
          print(snapshot.error);
          return const GenericErrorIndicator();
        }
        else {
          return const GenericLoadingIndicator(size: 50);
        }
      }
    );
  }
}