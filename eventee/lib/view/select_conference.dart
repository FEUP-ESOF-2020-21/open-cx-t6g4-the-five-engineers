
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:eventee/model/conference.dart';
import 'package:eventee/model/role.dart';
import 'package:eventee/view/view_conference.dart';
import 'package:eventee/view/create_conference.dart';
import 'package:eventee/view/utils/generic_separator.dart';
import 'package:eventee/view/utils/generic_error_indicator.dart';
import 'package:eventee/view/utils/generic_loading_indicator.dart';

class ConferenceSelection extends StatefulWidget {
  ConferenceSelection({Key key, this.role}) : super(key: key);

  final Role role;

  @override
  _ConferenceSelectionState createState() {
    if (this.role == Role.organizer) {
      return _ConferenceSelectionOrganizerState();
    }
    else {
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
      separatorBuilder: (context, index) => const GenericSeparator(),
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
            body = const GenericErrorIndicator();
          }
          else {
            body = const GenericLoadingIndicator();
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
          title: const Text('Select Conference')
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.search),
          onPressed: () {
            showSearch(
              context: context,
              delegate: ConferenceSearchDelegate(),
            );
          },
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

  List<QueryDocumentSnapshot> filterByTags(List<QueryDocumentSnapshot> snapshots) {
    List<String> tags = query.split(',');
    for (String tag in tags) { tag.trim(); }

    List<QueryDocumentSnapshot> filteredSnapshots = [];

    for (QueryDocumentSnapshot snapshot in snapshots) {
      if (matchingTags(snapshot, tags)) {
        // One of the conference tags corresponds to one of the query tags
        filteredSnapshots.add(snapshot);
      }
    }

    return filteredSnapshots;
  }

  bool matchingTags(QueryDocumentSnapshot snapshot, List<String> tags) {
    final Conference conference = Conference.fromDatabaseFormat(snapshot.data());

    for (String tag in tags) {
      if (conference.tags.contains(tag)) {
        return true;
      }
    }

    return false;
  }

  Widget _buildConferenceList(AsyncSnapshot<QuerySnapshot> snapshot) {
    _conferenceSnapshots = filterByTags(snapshot.data.docs);

    if (_conferenceSnapshots.length == 0) {
      return const Center(
        child: Text("No results found."),
      );
    }

    return ListView.separated(
      itemBuilder: _buildListItem,
      separatorBuilder: (context, index) => const GenericSeparator(),
      itemCount: _conferenceSnapshots.length,
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
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
              return const Center(
                child: Text("No results found."),
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
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Column();
  }
}
