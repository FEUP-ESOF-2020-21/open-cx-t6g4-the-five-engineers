
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventee/model/event.dart';
import 'package:eventee/model/role.dart';
import 'package:eventee/view/utils/generic_error_indicator.dart';
import 'package:eventee/view/utils/generic_loading_indicator.dart';
import 'package:eventee/view/utils/generic_separator.dart';
import 'package:eventee/view/view_event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';

import 'create_event.dart';

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
  List<QueryDocumentSnapshot> _eventSnapshots;
  static final int _maxDescriptionChars = 100, _maxTags = 3;

  Widget _buildListItem(BuildContext context, int index) {
    final QueryDocumentSnapshot eventSnapshot = _eventSnapshots[index];
    final Event event = Event.fromDatabaseFormat(eventSnapshot.data());

    return ListTile(
      title: Text(event.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              event.description.length > _maxDescriptionChars ?
              '${event.description.substring(0, _maxDescriptionChars)}...' :
              event.description
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Tags(
              itemCount: min(_maxTags, event.tags.length),
              itemBuilder: (int index) {
                final item = event.tags[index];

                return ItemTags(
                  key: Key(index.toString()),
                  index: index,
                  title: item,
                  active: true,
                  pressEnabled: false,
                );
              },
            ),
          ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ViewEvent(
            conferenceRef: widget.conferenceRef,
            eventRef: eventSnapshot.reference,
            userCredential: widget.userCredential,
            role: widget.role,
          )),
        );
      },
      trailing: Visibility(
        child: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Warning'),
                  content: const Text('Do you really wish to delete this event?'),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: const Text('Remove', style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        eventSnapshot.reference.delete()
                            .then((value) => Navigator.of(context).pop())
                            .catchError((error) {
                          print(error);
                          Navigator.of(context).pop();
                        });
                      },
                    )
                  ],
                ),
              );
            }
        ),
        visible: widget.role == Role.organizer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(
      // future: _refreshConference(),
      stream: widget.conferenceRef.collection('events').where("assignedUsers", arrayContains: widget.userCredential.user.uid).snapshots(),
      builder: (context, snapshot) {
        Widget body;

        if (snapshot.hasData) {
          _eventSnapshots = snapshot.data.docs;

          return Column(
            children: [
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text(
                        'Events',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Visibility(
                      child: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CreateEvent(conferenceRef: widget.conferenceRef))
                          );
                        },
                      ),
                      visible: widget.role == Role.organizer,
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
                itemCount: snapshot.data.docs.length,
                itemBuilder: _buildListItem,
                separatorBuilder: (content, index) => const GenericSeparator(),
                shrinkWrap: true,
              ),
            ],
          );
        }
        else if (snapshot.hasError) {
          print(snapshot.error);
          body = const GenericErrorIndicator();
        }
        else {
          body = const GenericLoadingIndicator();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('View Schedule'),
          ),
          body: body,
        );
      },
    );
  }
}