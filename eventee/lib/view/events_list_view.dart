
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:eventee/model/conference.dart';
import 'package:eventee/model/event.dart';
import 'package:eventee/view/create_event.dart';

class EventsListView extends StatefulWidget {
  EventsListView({Key key, this.conference}) : super(key: key);

  final Conference conference;

  @override
  _EventsListViewState createState() => _EventsListViewState();
}

class _EventsListViewState extends State<EventsListView> {
  static final int _maxDescriptionChars = 100, _maxTags = 3;

  Widget _buildListItem(BuildContext context, int index) {
    final Event event = widget.conference.events[index];

    return ListTile(
      title: Text(event.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.description.length > _maxDescriptionChars ? 
            '${event.description.substring(0, _maxDescriptionChars)}...' :
            event.description
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Tags(
              itemCount: min(_maxTags, event.tags.length),
              itemBuilder: (int index) {
                final item = event.tags[index];

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
    );
  }

  @override
  Widget build(context) {
    return Column(
      children: [
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  'Events',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Visibility(
                child: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    final Event ret = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateEvent())
                    );

                    if (ret != null) {
                      setState(() {
                        widget.conference.events.add(ret);
                      });
                    }
                  },
                ),
                visible: true, // TODO (replace with organizer check)
              )
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
          itemCount: widget.conference.events.length,
          itemBuilder: _buildListItem,
          separatorBuilder: (content, index) => const Divider(
            color: Colors.black54,
            thickness: 1.0,
          ),
          shrinkWrap: true,
        ),
      ],
    );
  }
}