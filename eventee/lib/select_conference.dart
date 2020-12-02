class MyConferenceSelection extends StatefulWidget {
  MyConferenceSelection({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyConferenceSelectionState createState() => _MyConferenceSelectionState();
}

class _MyConferenceSelectionState extends State<MyConferenceSelection> {
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
                      onTap: () { print("Edit Selected Conference: \n"); }     // TODO: view/edit conference menu
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

class InheritedBlocks extends InheritedWidget {
  InheritedBlocks({
    Key key,
    this.searchBlock,
    this.child
  }) : super(key: key, child: child);

  final Widget child;
  final SearchBlock searchBlock;

  @override
  bool updateShouldNotify(InheritedBlocks oldWidget) {
    return true;
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