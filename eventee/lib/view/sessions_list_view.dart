
import 'package:eventee/model/conference.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventee/model/role.dart';
import 'package:eventee/model/event.dart';
import 'package:eventee/model/session.dart';
import 'package:eventee/view/create_session.dart';
import 'package:eventee/view/utils/generic_error_indicator.dart';
import 'package:eventee/view/utils/generic_loading_indicator.dart';
import 'package:eventee/view/utils/generic_separator.dart';

class SessionsListView extends StatefulWidget {
  final DocumentReference conferenceRef, eventRef;
  final UserCredential userCredential;
  final Role role;

  SessionsListView({
    Key key,
    @required this.conferenceRef,
    @required this.eventRef,
    @required this.userCredential,
    @required this.role
  }) : super(key: key);

  @override
  _SessionsListViewState createState() => _SessionsListViewState();
}

class _SessionsListViewState extends State<SessionsListView> {
  static final DateFormat dateFormat = DateFormat('dd MMM, yyyy - HH:mm');
  static const TextStyle bold = TextStyle(fontWeight: FontWeight.bold);
  
  Conference _conference;
  Event _event;

  bool _givingAvailability = false;
  List<int> _availableSessions = [];

  Widget _buildListItem(BuildContext context, int index) {
    Session session = _event.sessions[index];

    List<InlineSpan> richText = [
      const TextSpan(text: 'From: ', style: bold),
      TextSpan(text: '${dateFormat.format(session.startDate)}\n'),
      const TextSpan(text: 'To: ', style: bold),
      TextSpan(text: '${dateFormat.format(session.endDate)}\n'),
    ];

    if (session.isAttendanceLimited()) {
      richText.addAll([
        const TextSpan(text: 'Attendance limited to '),
        TextSpan(text: '${session.attendanceLimit}', style: bold),
        const TextSpan(text: ' people'),
      ]);
    }

    List<Widget> rowChildren = [];

    if (widget.role == Role.organizer) {
      rowChildren = [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {}, // TODO
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Warning'),
                content: const Text('Do you really wish to delete this session?'),
                actions: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  TextButton(
                    child: const Text('Remove', style: TextStyle(color: Colors.red)),
                    onPressed: () {
                      _event.sessions.removeAt(index);

                      widget.eventRef.set(_event.toDatabaseFormat())
                          .then((value) => Navigator.of(context).pop())
                          .catchError((error) {
                            print(error);
                            Navigator.of(context).pop();
                          });
                    },
                  ),
                ],
              )
            );
          },
        ),
      ];
    }
    else if (_givingAvailability) {
      rowChildren = [
        Checkbox(
          value: _availableSessions.contains(index),
          onChanged: (bool value) {
            if (value) {
              if (!_availableSessions.contains(index)) {
                setState(() {
                  _availableSessions.add(index);
                });
              }
            }
            else {
              setState(() {
                _availableSessions.remove(index);
              });
            }
          },
        )
      ];
    }

    return ListTile(
      subtitle: Text.rich(TextSpan(children: richText)),
      title: Text('Session ${index + 1}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: rowChildren
      ),
    );
  }

  void _submitAvailability() {
    setState(() {
      _givingAvailability = false;
    });

    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot eventSnapshot = await transaction.get(widget.eventRef);
      
      Event event = Event.fromDatabaseFormat(eventSnapshot.data());

      for (Session session in event.sessions) {
        session.availabilities.remove(widget.userCredential.user.uid);
      }

      for (int index in _availableSessions) {
        if (event.sessions.length > index) {
          event.sessions[index].availabilities.add(widget.userCredential.user.uid);
        }
      }

      transaction.update(widget.eventRef, {'sessions': event.sessions.map((session) => session.toDatabaseFormat()).toList()});
    })
    .then((value) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
      )
    ))
    .catchError((error) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(error.toString()),
      )
    ));
  }

  @override
  Widget build(context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: widget.conferenceRef.snapshots(),
      builder: (context, conferenceSnapshot) {
        if (conferenceSnapshot.hasData) {
          _conference = Conference.fromDatabaseFormat(conferenceSnapshot.data.data());
          return StreamBuilder<DocumentSnapshot>(
            stream: widget.eventRef.snapshots(),
            builder: (context, eventSnapshot) {
              if (eventSnapshot.hasData) {
                _event = Event.fromDatabaseFormat(eventSnapshot.data.data());

                List<Widget> rowChildren = [];

                if (!_conference.schedulesGenerated) {
                  if (widget.role == Role.organizer) {
                    if (_event.sessions.length < Event.maxSessions) {
                      rowChildren.add(
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () async {
                            final Session ret = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CreateSession())
                            );

                            if (ret != null) {
                              _event.sessions.add(ret);
                              widget.eventRef.set(_event.toDatabaseFormat());
                            }
                          },
                        ),
                      );
                    }
                  }
                  else if (!_givingAvailability) {
                    rowChildren.add(
                      IconButton(
                        icon: const Icon(Icons.event_available),
                        onPressed: () {
                          setState(() {
                            _givingAvailability = true;
                            _availableSessions.clear();
                          });
                        },
                      ),
                    );
                  }
                  else {
                    rowChildren.addAll([
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _givingAvailability = false;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: _submitAvailability,
                      )
                    ]);
                  }
                }

                return Column(
                  children: [
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                              'Sessions (${_event.sessions.length} / ${Event.maxSessions})',
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Row(
                            children: rowChildren,
                          )
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
                      itemCount: eventSnapshot.data['sessions'].length,
                      itemBuilder: _buildListItem,
                      separatorBuilder: (context, index) => const GenericSeparator(),
                      shrinkWrap: true,
                    ),
                  ],
                );
              }
              else if (eventSnapshot.hasError) {
                print(eventSnapshot.error);
                return const GenericErrorIndicator();
              }
              else {
                return const GenericLoadingIndicator(size: 50);
              }
            }
          );
        }
        else if (conferenceSnapshot.hasError) {
          print(conferenceSnapshot.error);
          return const GenericErrorIndicator();
        }
        else {
          return const GenericLoadingIndicator(size: 50);
        }
      },
    );
  }
}