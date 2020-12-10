
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:eventee/model/event.dart';
import 'package:eventee/view/create_event.dart';
import 'package:eventee/view/view_event.dart';
import 'package:eventee/view/utils/generic_separator.dart';
import 'package:eventee/view/utils/generic_error_indicator.dart';
import 'package:eventee/view/utils/generic_loading_indicator.dart';

class EventsListView extends StatefulWidget {
  EventsListView({Key key, this.conferenceRef}) : super(key: key);

  final DocumentReference conferenceRef;

  @override
  _EventsListViewState createState() => _EventsListViewState();
}

class _EventsListViewState extends State<EventsListView> {
  static final int _maxDescriptionChars = 100, _maxTags = 3;

  List<QueryDocumentSnapshot> _eventSnapshots;

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
          MaterialPageRoute(builder: (context) => ViewEvent(conferenceRef: widget.conferenceRef, eventRef: eventSnapshot.reference)),
        );
      },
      trailing: IconButton(
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
    );
  }

  @override
  Widget build(context) {
    return StreamBuilder<QuerySnapshot>(
      stream: widget.conferenceRef.collection('events').snapshots(),
      builder: (context, snapshot) {
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
                      visible: true, // TODO (replace with organizer check)
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
          return const GenericErrorIndicator();
        }
        else {
          return const GenericLoadingIndicator(size: 50);
        }
      }
    );
  }
}