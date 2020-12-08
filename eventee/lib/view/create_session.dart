import 'package:eventee/model/session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_duration_picker/flutter_duration_picker.dart';

external DateTime add(Duration duration);

class CreateSession extends StatefulWidget {
  CreateSession({Key key}) : super(key: key);

  @override
  _CreateSessionState createState() => _CreateSessionState();
}

class _CreateSessionState extends State<CreateSession> {
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  bool _attendanceLimited = false;
  int _attendanceLimit;

  DateTime _startDate = DateTime(2000), _endDate = DateTime(2100);
  Duration _initialDuration = Duration(hours: 0, minutes: 30);
  void _pickStartDate() async {
    DateTime date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    TimeOfDay time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 0, minute: 0),
    );

    _startDate =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    startDateController.text = _startDate.toString().substring(0, 16);
  }

  void _pickDuration() async {
    _initialDuration = await showDurationPicker(
        context: context, initialTime: _initialDuration);

    _endDate = _startDate.add(_initialDuration);
    endDateController.text = _endDate.toString().substring(0, 16);
  }

  void _submitForm() {
    StringBuffer errorMessageBuffer = new StringBuffer();
    Duration maxDuration = Duration(hours: 24, minutes: 0);
    if (_initialDuration > maxDuration) {
      errorMessageBuffer.writeln("Duration can't be longer than 1 day!");
    }
    if (_endDate.isBefore(_startDate)) {
      errorMessageBuffer.writeln("End date is before start date!");
    }

    if (_attendanceLimited &&
        (_attendanceLimit == null || _attendanceLimit <= 0)) {
      errorMessageBuffer.writeln("Invalid attendance limit!");
    }

    if (errorMessageBuffer.isEmpty) {
      // Build session object
      Session session =
          Session(startDate: _startDate, endDate: _endDate, location: null);
      if (_attendanceLimited) {
        session.attendanceLimit = _attendanceLimit;
      }

      // Return to create event screen
      Navigator.pop(context, session);
    } else {
      // Error occurred: show an AlertDialog with the relevant error message
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text(errorMessageBuffer.toString()),
            );
          });
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
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                controller: endDateController,
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.access_time),
                  labelText: 'End Date',
                ),
                onTap: _pickDuration,
              ),
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
