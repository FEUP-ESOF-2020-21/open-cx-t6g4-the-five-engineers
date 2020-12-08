
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:eventee/model/conference.dart';
import 'package:eventee/view/view_conference.dart';
import 'package:eventee/view/create_conference.dart';
import 'package:eventee/view/utils/generic_loading_indicator.dart';
import 'package:flutter_tags/flutter_tags.dart';

class ConferenceSelection extends StatefulWidget {
  ConferenceSelection({Key key, this.type}) : super(key: key);

  final String title = "Select Conference";
  final String type;

  @override
  _ConferenceSelectionState createState() {
    if (this.type == "Organizer") {
      return _ConferenceSelectionOrganizerState();
    }
    else if (this.type == "Attendee") {
      return _ConferenceSelectionAttendeeState();
    }
  }
}

abstract class _ConferenceSelectionState extends State<ConferenceSelection> {}

class _ConferenceSelectionOrganizerState extends _ConferenceSelectionState {
  final CollectionReference ref = FirebaseFirestore.instance.collection('conferences');
  static const int maxTags = 5;

  List<QueryDocumentSnapshot> _conferenceSnapshots;

  Widget _buildListItem(BuildContext context, int index) {
    final QueryDocumentSnapshot conSnapshot = _conferenceSnapshots[index];
    final Conference conference = Conference.fromDatabaseFormat(conSnapshot.data());

    return ListTile(
      title: Text(conference.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(conference.description),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Tags(
              itemCount: min(maxTags, conference.tags.length),
              itemBuilder: (int index) {
                final String item = conference.tags[index];

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
            MaterialPageRoute(builder: (context) => ViewConference(ref: conSnapshot.reference))
        );
      },
    );
  }

  ListView _buildConferenceList(AsyncSnapshot<QuerySnapshot> snapshot) {
    _conferenceSnapshots = snapshot.data.docs;

    return ListView.separated(
      itemBuilder: _buildListItem,
      separatorBuilder: (context, index) => const Divider(
        color: Colors.black54,
        thickness: 1.0,
      ),
      itemCount: _conferenceSnapshots.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: ref.snapshots(),
        builder: (context, snapshot) {
          Widget body;

          if (snapshot.hasData) {
            body = _buildConferenceList(snapshot);
          }
          else if (snapshot.hasError) {
            print(snapshot.error);
          }
          else {
            body = GenericLoadingIndicator();
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Select Conference'),
            ),
            body: body,
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateConference())
                );
              },
            ),
          );
        }
    );
  }
}

class _ConferenceSelectionAttendeeState extends _ConferenceSelectionState {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title)
        ),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: false,
              title: Text("Search"),
              actions: <Widget> [
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: ConferenceSearchDelegate(),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
    );
  }
}

class ConferenceSearchDelegate extends SearchDelegate {
  final CollectionReference ref = FirebaseFirestore.instance.collection('conferences');
  static const int maxTags = 5;

  List<QueryDocumentSnapshot> _conferenceSnapshots;

  Widget _buildListItem(BuildContext context, int index) {
    final QueryDocumentSnapshot conSnapshot = _conferenceSnapshots[index];
    final Conference conference = Conference.fromDatabaseFormat(conSnapshot.data());

    return ListTile(
      title: Text(conference.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(conference.description),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Tags(
              itemCount: min(maxTags, conference.tags.length),
              itemBuilder: (int index) {
                final String item = conference.tags[index];

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
          MaterialPageRoute(builder: (context) => ViewConference(ref: conSnapshot.reference))
        );
      },
    );
  }

  ListView _buildConferenceList(AsyncSnapshot<QuerySnapshot> snapshot) {
    _conferenceSnapshots = snapshot.data.docs;

    return ListView.separated(
      itemBuilder: _buildListItem,
      separatorBuilder: (context, index) => const Divider(
        color: Colors.black54,
        thickness: 1.0,
      ),
      itemCount: _conferenceSnapshots.length,
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: ref.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.size != 0) {
              return _buildConferenceList(snapshot);
            }
            else {
              return Column(
                children: [
                  Text(
                    "No Results Found.",
                  ),
                ],
              );
            }
          }
          else if (snapshot.hasError) {
            return Column(
              children: [
                Text(
                  snapshot.error,
                ),
              ],
            );
          }
          else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: CircularProgressIndicator()),
              ],
            );
          }
        }
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Column();
  }
}
