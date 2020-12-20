
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:eventee/model/session.dart';

external DateTime add(Duration duration);

class CreateSession extends StatefulWidget {
  CreateSession({Key key}) : super(key: key);

  @override
  _CreateSessionState createState() => _CreateSessionState();
}

class _CreateSessionState extends State<CreateSession> {
  static final Duration maxDuration = Duration(hours: 24, minutes: 0);
  static final DateFormat dateFormat = DateFormat('dd MMM, yyyy - HH:mm');

  final startDateController = TextEditingController();

  bool _attendanceLimited = false;
  int _attendanceLimit;

  DateTime _startDate = DateTime(2000), _endDate = DateTime(2100);
  int _hours = 1, _minutes = 0;
  
  void _pickStartDate() async {
    DateTime date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    TimeOfDay time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 0, minute: 0),
    );

    if (time == null) return;

    _startDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);

    setState(() {
      startDateController.text = dateFormat.format(_startDate);
      _endDate = _startDate.add(Duration(hours: _hours, minutes: _minutes));
    });
  }

  void _hoursChanged(newValue) {
    setState(() {
      _hours = newValue;
      _endDate = _startDate.add(Duration(hours: _hours, minutes: _minutes));
    });
  }

  void _minutesChanged(newValue) {
    setState(() {
      _minutes = newValue;
      _endDate = _startDate.add(Duration(hours: _hours, minutes: _minutes));
    });
  }

  void _submitForm() {
    StringBuffer errorMessageBuffer = new StringBuffer();
    
    Duration duration = Duration(hours: _hours, minutes: _minutes);

    if (startDateController.text.isEmpty) {
      errorMessageBuffer.writeln("Start date not entered!");
    }

    if (duration > maxDuration) {
      errorMessageBuffer.writeln("Duration can't be longer than 1 day!");
    }

    if (duration == Duration(hours: 0, minutes: 0)) {
      errorMessageBuffer.writeln("Duration can't be zero!");
    }

    if (_endDate.isBefore(_startDate)) {
      errorMessageBuffer.writeln("End date is before start date!");
    }

    if (_attendanceLimited && (_attendanceLimit == null || _attendanceLimit <= 0)) {
      errorMessageBuffer.writeln("Invalid attendance limit!");
    }

    if (errorMessageBuffer.isEmpty) {
      // Build session object
      Session session = Session(startDate: _startDate, endDate: _endDate, location: null, availabilities: LinkedHashSet());
      if (_attendanceLimited) {
        session.attendanceLimit = _attendanceLimit;
      }

      // Return to create event screen
      Navigator.pop(context, session);
    }
    else {
      // Error occurred: show an AlertDialog with the relevant error message
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(errorMessageBuffer.toString()),
          );
        }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Session'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                controller: startDateController,
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.calendar_today),
                  labelText: 'Start Date',
                ),
                onTap: _pickStartDate,
              ),
            ),
            const Text(
              'Duration (hours / minutes)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NumberPicker.integer(
                  initialValue: _hours,
                  maxValue: 24,
                  minValue: 0,
                  onChanged: _hoursChanged,
                ),
                NumberPicker.integer(
                  initialValue: _minutes,
                  maxValue: 55,
                  minValue: 0,
                  step: 5,
                  onChanged: _minutesChanged,
                  zeroPad: true,
                ),
              ],
            ),
            Visibility(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text.rich(
                    TextSpan(
                      children: <TextSpan>[
                        TextSpan(text: 'End Date: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: '${dateFormat.format(_endDate)}'),
                      ],
                    ),
                    style: const TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
                visible: startDateController.text.isNotEmpty,
            ),
            SwitchListTile(
              title: const Text('Limited attendance'),
              onChanged: (bool newValue) {
                setState(() {
                  _attendanceLimited = newValue;
                });
              },
              value: _attendanceLimited,
            ),
            Visibility(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextField(
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Limit',
                    suffixIcon: const Icon(Icons.people),
                  ),
                  onChanged: (String newValue) {
                    _attendanceLimit = int.tryParse(newValue);
                  },
                  keyboardType: TextInputType.number,
                ),
              ),
              visible: _attendanceLimited,
            ),
            RaisedButton(
              child: const Text('Create'),
              onPressed: _submitForm,
            ),
          ],
        ),
      ),
    );
  }
}
