
import 'package:eventee/view/create_session.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:eventee/model/session.dart';

class CreateEvent extends StatefulWidget {
  CreateEvent({Key key}) : super(key: key);

  @override
  _CreateEventState createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
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
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Name'
                ),
                maxLength: 50,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 15.0),
              child: TextField(
                decoration: InputDecoration(
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
                }
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
                      'Sessions',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
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
              onPressed: () {},
              child: Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}