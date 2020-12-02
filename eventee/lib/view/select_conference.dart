import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventee/model/conference.dart';
import 'package:flutter/material.dart';

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

  final String title = "Select Conference";

  @override
  _ConferenceSelectionOrganizerState createState() => _ConferenceSelectionOrganizerState();
}

class _ConferenceSelectionOrganizerState extends State<ConferenceSelectionOrganizer> {
  bool started = false;

  List<String> tags;
  List<Widget> tabsPanel;

  List<String> conferences;
  List<Widget> conferencesPanel;

  obtainTags() {
    tags = ["Scheduled", "In course", "Past"];
  }

  createTabs() {
    tabsPanel = [];
    for (int i = 0; i < tags.length; ++ i) {
      tabsPanel.add(Tab(
        text: tags[i],
      ));
    }
  }

  obtainConferences(String tag) {
    conferences = ["Conference 1", "Conference 2", "Conference 3", "Conference 4", "Conference 5", "Conference 6"];
    //TODO: obtain conferences from database
  }

  createConferencesPanel() {
    conferencesPanel = [];
    var conferencesPanelAux;
    for (int i = 0; i < tags.length; ++i) {
      conferencesPanelAux = <Widget>[];
      obtainConferences(tags[i]);
      for (int j = 0; j < conferences.length; ++j) {
        conferencesPanelAux.add(ListTile(
            title: Text(conferences[j]),
            onTap: () { print("Edit Selected Conference: " + conferences[j] + "\n"); }     // TODO: view/edit conference menu
        ),);
      }
      conferencesPanel.add(Column(
        children: conferencesPanelAux,
      ),);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!started) {
      obtainTags();
      createConferencesPanel();
      createTabs();
      started = true;
    }

    return DefaultTabController(
      length: tags.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          bottom: TabBar(
            tabs: tabsPanel,
          ),
        ),
        body: TabBarView(
          children: conferencesPanel,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            print("Add Conference\n");
            // TODO : add conference
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.blue,
        ),
      ),
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
