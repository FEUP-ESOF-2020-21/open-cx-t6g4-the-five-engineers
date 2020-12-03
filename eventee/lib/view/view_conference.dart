
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:eventee/model/conference.dart';
import 'package:eventee/model/event.dart';
import 'package:eventee/view/events_list_view.dart';
import 'package:eventee/view/utils/generic_loading_indicator.dart';

class ViewConference extends StatefulWidget {
  final DocumentReference ref;

  ViewConference({Key key, this.ref}) : super(key: key);

  @override
  _ViewConferenceState createState() => _ViewConferenceState();
}

class _ViewConferenceState extends State<ViewConference> {
  Future<Conference> _refreshConference() {
    Future<DocumentSnapshot> snapshot = widget.ref.get();
    return snapshot.then((value) => Conference.fromDatabaseFormat(value.data()));
  }

  Future<Conference> _sampleConference = Future.delayed(Duration(seconds: 1)).then((value) => Conference(
    name: 'SampleCon',
    description: 'A sample description! Wow!',
    startDate: DateTime.parse('2020-12-11'),
    endDate: DateTime.parse('2020-12-13'),
    location: 'Porto, Portugal',
    tags: ['test tag', 'another one'],
    events: [Event(name: 'Programming contest', description: 'This event has a sample description! But it is more than 100 chars so it will get clipped',
        tags: ['programming', 'python', 'c'], sessions: [])],
  ));

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Conference>(
      future: _sampleConference,
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
                  padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
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
              EventsListView(conferenceRef: widget.ref),
            ],
          );
        }
        else if (snapshot.hasError) {
          print(snapshot.error);
          body = const Center(
            child: Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 80,
            ),
          );
        }
        else {
          body = GenericLoadingIndicator();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('View Conference'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {},
              ),
            ],
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
