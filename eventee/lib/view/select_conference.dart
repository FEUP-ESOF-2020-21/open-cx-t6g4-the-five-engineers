
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:eventee/model/conference.dart';
import 'package:eventee/view/view_conference.dart';
import 'package:eventee/view/create_conference.dart';
import 'package:eventee/view/utils/generic_error_indicator.dart';
import 'package:eventee/view/utils/generic_loading_indicator.dart';

class ConferenceSelectionAttendee extends StatefulWidget {
  ConferenceSelectionAttendee({Key key}) : super(key: key);

  final String title = "Select Conference";

  @override
  _ConferenceSelectionAttendeeState createState() => _ConferenceSelectionAttendeeState();
}

class _ConferenceSelectionAttendeeState extends State<ConferenceSelectionAttendee> {
  bool started = false;

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
                      delegate: CustomSearchDelegate(),
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

class ConferenceSelectionOrganizer extends StatefulWidget {
  ConferenceSelectionOrganizer({Key key}) : super(key: key);

  @override
  _ConferenceSelectionOrganizerState createState() => _ConferenceSelectionOrganizerState();
}

class _ConferenceSelectionOrganizerState extends State<ConferenceSelectionOrganizer> {
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
          body = const GenericErrorIndicator();
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

class CustomSearchDelegate extends SearchDelegate {
  /*
      https://medium.com/codechai/implementing-search-in-flutter-17dc5aa72018
   */
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = ''; //TODO
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

    // The SearchBlock will handle the search for the conferences
    // The Results will be on the results stream.
    SearchBlock.search(query);

    return Column(
      children: <Widget> [
        // Build the results based on the searchResults stream in the searchBloc
        StreamBuilder(
          //stream: SearchBlock.results,
          builder: (context, AsyncSnapshot<List<Result>> snapshot) {
            if (!snapshot.hasData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget> [
                  Center(child: CircularProgressIndicator()),
                ],
              );
            }
            else if (snapshot.data.length == 0) {
              return Column(
                children: <Widget> [
                  Text(
                    "No Results Found.",
                  ),
                ],
              );
            }
            else {
              var results = snapshot.data;
              return ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  var result = results[index];
                  return ListTile(
                      title: Text(result.title),
                      onTap: () { print("Edit Selected Conference\n"); }     // TODO: view/edit conference menu
                  );
                },
              );
            }
          },
        ),
      ],
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // This method is called every time the search term changes.
    // If you want to add search suggestions as the user enters their search term, this is the place to do that.
    return Column();
  }
}

class SearchBlock {
  static Stream<Result> results;

  static void search(String query) {
    // Perform the Search on the Database and place the answer on the Results Stream
    // TODO
    return;
  }
}

class Result {
  String data;
  String title;
}
