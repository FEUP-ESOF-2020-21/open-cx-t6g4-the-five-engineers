
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventee/view/create_session.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:eventee/model/event.dart';
import 'package:eventee/model/session.dart';

class CreateEvent extends StatefulWidget {
  CreateEvent({Key key, this.conferenceRef}) : super(key: key);

  final DocumentReference conferenceRef;

  @override
  _CreateEventState createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  static const int maxSessions = 100;
  static const int maxTags = 50;

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<String> _tags = new List();
  List<Session> _sessions = new List();

  Widget _buildListItem(BuildContext context, int index) {
    final Session session = _sessions[index];

    // TODO: Improve how sessions are displayed (user interface)
    StringBuffer buf = new StringBuffer();
    buf.writeln('From ${session.startDate.toString().substring(0, 16)}'
        ' to ${session.endDate.toString().substring(0, 16)}');

    if (session.isAttendanceLimited()) {
      buf.write('Attendance limited to ${session.attendanceLimit} people');
    }

    return ListTile(
      subtitle: Text(buf.toString()),
      title: Text('Session ${index + 1}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {}, // TODO
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              setState(() {
                _sessions.removeAt(index);
              });
            },
          ),
        ],
      ),

    );
  }

  void _submitForm() {
    StringBuffer errorMessageBuffer = new StringBuffer();

    if (_nameController.text.isEmpty) {
      errorMessageBuffer.writeln('Name not entered!');
    }
    if (_descriptionController.text.isEmpty) {
      errorMessageBuffer.writeln('Description not entered!');
    }
    if (_sessions.isEmpty) {
      errorMessageBuffer.writeln('Event must have at least one session!');
    }

    if (errorMessageBuffer.isEmpty) {
      Event event = new Event(
        name: _nameController.text,
        description: _descriptionController.text,
        tags: _tags,
        sessions: _sessions
      );
      
      widget.conferenceRef.collection('events').add(event.toDatabaseFormat())
          .then(
            (value) async {
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Success!'),
                )
              );

              Navigator.pop(context, event);
            }
          )
          .catchError(
            (error) async {
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Error'),
                  content: Text('Information: $error'),
                )
              );

              Navigator.pop(context);
            }
          );
    }
    else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessageBuffer.toString()),
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create an Event'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 7.5),
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Name'
                ),
                maxLength: 50,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 15.0),
              child: TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Description'
                ),
                maxLines: 3,
                maxLength: 1000,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 15.0),
              child: Text(
                'Tags (${_tags.length} / $maxTags)',
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Tags(
              textField: TagsTextField(
                autofocus: false,
                padding: const EdgeInsets.all(15.0),
                width: double.infinity,
                inputDecoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.tag),
                ),
                maxLength: 50,
                onSubmitted: (String str) {
                  setState(() {
                    _tags.add(str);
                  });
                },
                enabled: _tags.length < maxTags,
              ),
              itemCount: _tags.length,
              itemBuilder: (int index) {
                final tag = _tags[index];

                return ItemTags(
                  key: Key(index.toString()),
                  index: index,
                  title: tag,
                  active: true,
                  removeButton: ItemTagsRemoveButton(
                    onRemoved: () {
                      setState(() {
                        _tags.removeAt(index);
                      });
                      return true;
                    }
                  ),
                );
              },
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      'Sessions (${_sessions.length} / $maxSessions)',
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Visibility(
                    child: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () async {
                        final Session ret = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CreateSession())
                        );

                        if (ret != null) {
                          setState(() {
                            _sessions.add(ret);
                          });
                        }
                      },
                    ),
                    visible: _sessions.length < maxSessions,
                  ),
                ],
              ),
              decoration: BoxDecoration(
                color: Colors.blue[200],
                border: Border.all(
                  color: Colors.blueAccent,
                  width: 3.0,
                ),
              ),
            ),
            ListView.separated(
              itemCount: _sessions.length,
              itemBuilder: _buildListItem,
              separatorBuilder: (context, index) => const Divider(
                color: Colors.black54,
                thickness: 1.0,
              ),
              shrinkWrap: true,
            ),
            RaisedButton(
              onPressed: _submitForm,
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}