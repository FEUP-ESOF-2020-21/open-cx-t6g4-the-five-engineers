
import 'package:eventee/scheduling_algorithm.dart';
import 'package:eventee/view/schedule.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:eventee/model/role.dart';
import 'package:eventee/model/conference.dart';
import 'package:eventee/model/event.dart';
import 'package:eventee/view/events_list_view.dart';
import 'package:eventee/view/utils/generic_error_indicator.dart';
import 'package:eventee/view/utils/generic_loading_indicator.dart';

class ViewConference extends StatefulWidget {
  final DocumentReference ref;
  final UserCredential userCredential;
  final Role role;

  ViewConference({
    Key key, 
    @required this.ref,
    @required this.userCredential,
    @required this.role
  }) : super(key: key);

  @override
  _ViewConferenceState createState() => _ViewConferenceState();
}

class _ViewConferenceState extends State<ViewConference> {
  Future<Conference> _refreshConference() {
    Future<DocumentSnapshot> snapshot = widget.ref.get();
    return snapshot.then((value) => Conference.fromDatabaseFormat(value.data()));
  }

  void _generateSchedules() async {
    await widget.ref.update({'schedules_generated': true});
    
    widget.ref.get().then(
      (conferenceSnapshot) async {
        Conference conference = Conference.fromDatabaseFormat(conferenceSnapshot.data());
        QuerySnapshot eventsSnapshot = await conferenceSnapshot.reference.collection('events').get();

        conference.events = [];

        for (var eventSnapshot in eventsSnapshot.docs) {
          conference.events.add(Event.fromDatabaseFormat(eventSnapshot.data()));
        }

        generateSchedules(conference);

        for (int i = 0; i < eventsSnapshot.docs.length; ++i) {
          await eventsSnapshot.docs[i].reference.update({
            'sessions': conference.events[i].sessions.map((session) => session.toDatabaseFormat()).toList()
          })
          .catchError((error) => showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: Text(error.toString()),
            )
          ));
        }

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
          )
        );
      }
    )
    .catchError(
      (error) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(error.toString()),
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Conference>(
      future: _refreshConference(),
      builder: (context, snapshot) {
        Widget body;

        if (snapshot.hasData) {
          body = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 7.5),
                  child: Text(
                    '${snapshot.data.name}',
                    style: const TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 7.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text('From', style: TextStyle(fontSize: 16.0)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.blue[200],
                        borderRadius: const BorderRadius.all(Radius.circular(15.0))
                      ),
                      child: Text(
                        '${snapshot.data.startDate.toString().substring(0, 10)}',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                    const Text('To', style: TextStyle(fontSize: 16.0)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.blue[200],
                        borderRadius: const BorderRadius.all(Radius.circular(15.0))
                      ),
                      child: Text(
                        '${snapshot.data.endDate.toString().substring(0, 10)}',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 7.5),
                  child: Tags(
                    itemCount: snapshot.data.tags.length,
                    itemBuilder: (int index) {
                      List<String> tags = snapshot.data.tags;
                      final item = tags[index];

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
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 7.5),
                child: Text(
                  '${snapshot.data.description}',
                  style: const TextStyle(
                    fontSize: 15.0,
                  ),
                ),
              ),
              EventsListView(conferenceRef: widget.ref, userCredential: widget.userCredential, role: widget.role),
              Center(
                child: widget.role == Role.organizer ? 
                  snapshot.data.schedulesGenerated ?
                  const Text('Schedules already generated', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0))
                  :
                  RaisedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Warning'),
                          content: const Text('Do you really wish to generate schedules for this conference?'),
                          actions: [
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            TextButton(
                              child: const Text('Generate'),
                              onPressed: _generateSchedules,
                            ),
                          ],
                        )
                      );
                    },
                    icon: const Icon(Icons.event_available),
                    label: const Text('Generate Schedules'),
                  )
                  :
                  Visibility(
                    child: RaisedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => Schedule(
                            conferenceRef: widget.ref,
                            userCredential: widget.userCredential,
                            role: widget.role,
                          ))
                        );
                      },
                      icon: const Icon(Icons.event_available),
                      label: const Text('View your Schedule'),
                    ),
                    visible: snapshot.data.schedulesGenerated,
                  )
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
            title: const Text('View Conference'),
            actions: widget.role == Role.organizer ? [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {},
              ),
            ]
            : [],
          ),
          body: SingleChildScrollView(child: body),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        );
      },
    );
  }
}
