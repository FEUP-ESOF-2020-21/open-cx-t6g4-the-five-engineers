
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
  Event event;

  Widget _buildListItem(BuildContext context, int index) {
    // TODO
  }

  @override
  Widget build(context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: widget.eventRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          event = Event.fromDatabaseFormat(snapshot.data.data());

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