
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:eventee/model/role.dart';
import 'package:eventee/model/event.dart';
import 'package:eventee/view/sessions_list_view.dart';
import 'package:eventee/view/utils/generic_error_indicator.dart';
import 'package:eventee/view/utils/generic_loading_indicator.dart';

class ViewEvent extends StatefulWidget {
  final DocumentReference conferenceRef, eventRef;
  final UserCredential userCredential;
  final Role role;

  ViewEvent({
    Key key,
    @required this.conferenceRef,
    @required this.eventRef,
    @required this.userCredential,
    @required this.role
  }) : super(key: key);

  @override
  _ViewEventState createState() => _ViewEventState();
}

class _ViewEventState extends State<ViewEvent> {
  Future<Event> _refreshEvent() {
    Future<DocumentSnapshot> snapshot = widget.eventRef.get();
    return snapshot.then((value) => Event.fromDatabaseFormat(value.data()));
  }

  @override
  Widget build(context) {
    return FutureBuilder<Event>(
      future: _refreshEvent(),
      builder: (context, snapshot) {
        Widget body;

        if (snapshot.hasData) {
          body = SingleChildScrollView(
            child: Column(
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
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 7.5),
                    child: Tags(
                      itemCount: snapshot.data.tags.length,
                      itemBuilder: (int index) {
                        final item = snapshot.data.tags[index];

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
                SessionsListView(
                  conferenceRef: widget.conferenceRef,
                  eventRef: widget.eventRef,
                  userCredential: widget.userCredential,
                  role: widget.role
                ),
              ],
            ),
          );
        }
        else if (snapshot.hasError) {
          print(snapshot.error);
          body = const GenericErrorIndicator();
        }
        else {
          body = GenericLoadingIndicator();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('View Event'),
            actions: widget.role == Role.organizer ? [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {},
              ),
            ]
            : [],
          ),
          body: body,
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