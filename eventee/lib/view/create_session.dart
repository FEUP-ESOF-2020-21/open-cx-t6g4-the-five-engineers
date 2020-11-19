
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateSession extends StatefulWidget {
  CreateSession({Key key}) : super(key: key);

  @override
  _CreateSessionState createState() => _CreateSessionState();
}

class _CreateSessionState extends State<CreateSession> {
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  bool _attendanceLimited = false;

  DateTime _startDate = DateTime(2000), _endDate = DateTime(2100);

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

    _startDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    startDateController.text = _startDate.toString().substring(0, 16);
  }

  void _pickEndDate() async {
    DateTime date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: _startDate,
      lastDate: DateTime(2100),
    );

    TimeOfDay time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 0, minute: 0),
    );

    _endDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    endDateController.text = _endDate.toString().substring(0, 16);
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
                  suffixIcon: const Icon(Icons.calendar_today),
                  labelText: 'End Date', 
                ),
                onTap: _pickEndDate,
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
                  keyboardType: TextInputType.number,
                ),
              ),
              visible: _attendanceLimited,
            ),
            RaisedButton(
              child: const Text('Create'),
              onPressed: () {}, // TODO
            ),
          ],
        ),
      ),
    );
  }
}
