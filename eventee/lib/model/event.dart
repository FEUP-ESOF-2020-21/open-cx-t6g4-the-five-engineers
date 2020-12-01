
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

  Event.fromDatabaseFormat(Map<String, dynamic> map) {
    name = map['name'];
    description = map['description'];
    tags = map['tags'];
    sessions = map['sessions'].map((sessionMap) => Session.fromDatabaseFormat(sessionMap));
  }

  Map<String, dynamic> toDatabaseFormat() {
    return {
      'name': name,
      'description': description,
      'tags': tags,
      'sessions': sessions.map((session) => session.toDatabaseFormat()),
    };
  }
}