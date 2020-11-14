
import 'package:flutter/foundation.dart';
import 'package:eventee/model/session.dart';

class Event {
  String name;
  String description;
  List<String> tags;
  List<Session> sessions;

  Event({
    @required this.name,
    @required this.description,
    @required this.tags,
    @required this.sessions
  });
}