
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:eventee/model/event.dart';
import 'package:eventee/view/create_event.dart';
import 'package:eventee/view/view_event.dart';
import 'package:eventee/view/utils/generic_separator.dart';
import 'package:eventee/view/utils/generic_error_indicator.dart';
import 'package:eventee/view/utils/generic_loading_indicator.dart';

class Schedule extends StatefulWidget {
  Schedule({Key key, this.conferenceRef}) : super(key: key);
  
  final DocumentReference conferenceRef;

  @override
  _ScheduleState createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  List<QueryDocumentSnapshot> _eventSnapshots;

  @override
  Widget build(context) {
    return Column();
  }
}