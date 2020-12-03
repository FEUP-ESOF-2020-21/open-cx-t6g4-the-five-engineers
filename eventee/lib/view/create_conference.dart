
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventee/model/conference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';

class CreateConference extends StatefulWidget {
  CreateConference({Key key}) : super(key: key);

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

          if (messageBuffer.isEmpty) {
            DateTime startDate = DateTime.parse(startDateController.text),
                endDate = DateTime.parse(endDateController.text);

            if (endDate.isBefore(startDate)) {
              messageBuffer.writeln('End date is before start date!');
            }
            else {
              Conference conference = new Conference(
                name: nameController.text,
                startDate: startDate,
                endDate: endDate,
                location: locationController.text,
                description: descriptionController.text,
                tags: _tags,
                events: [],
              );

              CollectionReference conferences = FirebaseFirestore.instance.collection('conferences');

              conferences.add(conference.toDatabaseFormat())
                  .then((value) => messageBuffer.writeln('Success!'))
                  .catchError((error) => messageBuffer.writeln(
                  'Error occurred when creating conference: $error'));
            }
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
