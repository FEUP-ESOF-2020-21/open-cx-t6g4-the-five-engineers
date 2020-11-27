
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
  }) {
    events = new List();
  }
}