
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:eventee/model/event.dart';

class ViewEvent extends StatefulWidget {
  final DocumentReference ref;

  ViewEvent({Key key, this.ref}) : super(key: key);

  @override
  _ViewEventState createState() => _ViewEventState();
}

class _ViewEventState extends State<ViewEvent> {
  Future<Event> _refreshEvent() {
    Future<DocumentSnapshot> snapshot = widget.ref.get();
    return snapshot.then((value) => Event.fromDatabaseFormat(value.data()));
  }

  @override
  Widget build(context) {
    return FutureBuilder(
      future: _refreshEvent(),
      builder: (context, snapshot) {
        Widget body;

        if (snapshot.hasData) {
          body = SingleChildScrollView(
            child: Column(
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
              ],
            ),
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
          body = Center(
            child: SizedBox(
              child: CircularProgressIndicator(),
              width: 80,
              height: 80,
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('View Event'),
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