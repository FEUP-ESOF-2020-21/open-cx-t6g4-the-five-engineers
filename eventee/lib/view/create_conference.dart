
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eventee/model/conference.dart';

class CreateConference extends StatefulWidget {
  CreateConference({Key key, @required this.userCredential}) : super(key: key);

  final UserCredential userCredential;

  @override
  _CreateConferenceState createState() => _CreateConferenceState();
}

class _CreateConferenceState extends State<CreateConference> {
  final nameController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();

  List<String> _tags = new List();

  void createConference() {
    final StringBuffer messageBuffer = new StringBuffer();

    final DateTime startDate = DateTime.tryParse(startDateController.text),
        endDate = DateTime.tryParse(endDateController.text);

    if (nameController.text.isEmpty) {
      messageBuffer.writeln('Name not entered!');
    }
    if (startDate == null) {
      messageBuffer.writeln('Start date not entered!');
    }
    if (endDate == null) {
      messageBuffer.writeln('End date not entered!');
    }
    if (locationController.text.isEmpty) {
      messageBuffer.writeln('Location not entered!');
    }
    if (descriptionController.text.isEmpty) {
      messageBuffer.writeln('Description not entered!');
    }

    if (messageBuffer.isEmpty) {
      if (endDate.isBefore(startDate)) {
        messageBuffer.writeln('End date is before start date!');
      }
      else {
        final Conference conference = new Conference(
          name: nameController.text,
          organizerUid: widget.userCredential.user.uid,
          startDate: startDate,
          endDate: endDate,
          location: locationController.text,
          description: descriptionController.text,
          tags: _tags,
          events: [],
        );

        // Add new conference to database
        final CollectionReference conferences = FirebaseFirestore.instance.collection('conferences');

        conferences.add(conference.toDatabaseFormat())
          .then((value) => Navigator.pop(context))
          .catchError((error) => messageBuffer.writeln('Error occurred when creating conference: $error'));
      }
    }

    // If an error occurred, show an AlertDialog with the error message
    if (messageBuffer.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(messageBuffer.toString()),
          );
        }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Conference'),
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
                autofocus: false,
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
                    _tags.add(str);
                  });
                },
              ),
              itemCount: _tags.length,
              itemBuilder: (int index) {
                final item = _tags[index];

                return ItemTags(
                  key: Key(index.toString()),
                  index: index,
                  title: item,
                  active: true,
                  removeButton: ItemTagsRemoveButton(
                    onRemoved: () {
                      setState(() {
                        _tags.removeAt(index);
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
