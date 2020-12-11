
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:eventee/model/event.dart';

class Conference {
  String name;
  String organizerUid;
  DateTime startDate, endDate;
  String location;
  String description;
  List<String> tags;
  List<Event> events;

  static const int maxTags = 50;

  Conference({
    @required this.name,
    @required this.organizerUid,
    @required this.startDate,
    @required this.endDate,
    @required this.location,
    @required this.description,
    @required this.tags,
    @required this.events,
  });

  Conference.fromDatabaseFormat(Map<String, dynamic> map) {
    name = map['name'];
    organizerUid = map['organizer_uid'];
    startDate = DateTime.fromMillisecondsSinceEpoch(map['start_date'].millisecondsSinceEpoch);
    endDate = DateTime.fromMillisecondsSinceEpoch(map['end_date'].millisecondsSinceEpoch);
    location = map['location'];
    description = map['description'];
    tags = List.castFrom(map['tags']);
  }

  Map<String, dynamic> toDatabaseFormat() {
    return {
      'name': name,
      'organizer_uid': organizerUid,
      'start_date': new Timestamp.fromDate(startDate),
      'end_date': new Timestamp.fromDate(endDate),
      'location': location,
      'description': description,
      'tags': tags,
    };
  }
}