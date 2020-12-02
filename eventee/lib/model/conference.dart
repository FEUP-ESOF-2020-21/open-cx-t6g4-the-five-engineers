
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:eventee/model/event.dart';

class Conference {
  String name;
  DateTime startDate, endDate;
  String location; // May change after Google Places integration
  String description;
  List<String> tags;
  List<Event> events;

  Conference({
    @required this.name,
    @required this.startDate,
    @required this.endDate,
    @required this.location,
    @required this.description,
    @required this.tags,
    @required this.events,
  });

  Conference.fromDatabaseFormat(Map<String, dynamic> map) {
    name = map['name'];
    startDate = DateTime.fromMillisecondsSinceEpoch(map['start_date'].millisecondsSinceEpoch);
    endDate = DateTime.fromMillisecondsSinceEpoch(map['end_date'].millisecondsSinceEpoch);
    location = map['location'];
    description = map['description'];
    tags = List.castFrom(map['tags']);
  }

  Map<String, dynamic> toDatabaseFormat() {
    return {
      'name': name,
      'start_date': new Timestamp.fromDate(startDate),
      'end_date': new Timestamp.fromDate(endDate),
      'location': location,
      'description': description,
      'tags': tags,
    };
  }
}