import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyConferenceSelection(title: 'Select a Conference'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final nameController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();

  List _items = new List();

  Future<dynamic> createConference() {
    return showDialog(
        context: context,
        builder: (context) {
          StringBuffer messageBuffer = new StringBuffer();

          if (nameController.text.isEmpty) {
            messageBuffer.writeln('Name not entered!');
          }
          if (startDateController.text.isEmpty) {
            messageBuffer.writeln('Start date not entered!');
          }
          if (endDateController.text.isEmpty) {
            messageBuffer.writeln('End date not entered!');
          }
          if (locationController.text.isEmpty) {
            messageBuffer.writeln('Location not entered!');
          }
          if (descriptionController.text.isEmpty) {
            messageBuffer.writeln('Description not entered!');
          }

          DateTime startDate = DateTime.parse(startDateController.text),
              endDate = DateTime.parse(endDateController.text);

          if (endDate.isBefore(startDate)) {
            messageBuffer.writeln('End date is before start date!');
          }

          if (messageBuffer.isEmpty) {
            messageBuffer.writeln('Success!');
          }

          return AlertDialog(
            content: Text(messageBuffer.toString()),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Name'
                ),
                maxLength: 50,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15.0, 15.0, 7.5, 15.0),
                    child: TextField(
                      readOnly: true,
                      controller: startDateController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                        labelText: 'Start Date'
                      ),
                      onTap: () async {
                        DateTime date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100)
                        );
                        startDateController.text = date.toString().substring(0, 10);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(7.5, 15.0, 15.0, 15.0),
                    child: TextField(
                      readOnly: true,
                      controller: endDateController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                          labelText: 'End Date'
                      ),
                      onTap: () async {
                        DateTime date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100)
                        );
                        endDateController.text = date.toString().substring(0, 10);
                      },
                    ),
                  ),
                ),
              ],
            ),
            // TODO: Google Places autocomplete integration
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.location_on),
                  labelText: 'Location',
                ),
                maxLength: 100,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Description'
                ),
                maxLines: 3,
                maxLength: 1000,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Tags',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Tags(
              textField: TagsTextField(
                padding: const EdgeInsets.all(15.0),
                width: double.infinity,
                inputDecoration: InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.tag),
                ),
                maxLength: 50,
                onSubmitted: (String str) {
                  setState(() {
                    _items.add(str);
                  });
                },
              ),
              itemCount: _items.length,
              itemBuilder: (int index) {
                final item = _items[index];

                return ItemTags(
                  key: Key(index.toString()),
                  index: index,
                  title: item,
                  active: true,
                  removeButton: ItemTagsRemoveButton(
                    onRemoved: () {
                      setState(() {
                        _items.removeAt(index);
                      });
                      return true;
                    },
                  ),
                );
              },
            ),
            RaisedButton(
              onPressed: createConference,
              child: Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}

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