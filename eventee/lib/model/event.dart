
import 'package:flutter/foundation.dart';
import 'package:eventee/model/session.dart';

class Event {
  String name;
  String description;
  List<String> tags;
  List<Session> sessions;

  static const int maxTags = 50;
  static const int maxSessions = 100;

  Event({
    @required this.name,
    @required this.description,
    @required this.tags,
    @required this.sessions
  });

  Event.fromDatabaseFormat(Map<String, dynamic> map) {
    name = map['name'];
    description = map['description'];
    tags = List.castFrom(map['tags']);
    sessions = List.castFrom(map['sessions'].map((sessionMap) => Session.fromDatabaseFormat(sessionMap)).toList());
  }

  Map<String, dynamic> toDatabaseFormat() {
    return {
      'name': name,
      'description': description,
      'tags': tags,
      'sessions': sessions.map((session) => session.toDatabaseFormat()).toList(),
    };
  }

  Session getSession(int index) {
    return this.sessions[index];
  }
}