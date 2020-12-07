import 'package:flutter/material.dart';
import 'package:eventee/view/select_conference.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _fullNameController = TextEditingController(),
      _emailController = TextEditingController(),
      _passwordController = TextEditingController(),
      _confirmPasswordController = TextEditingController();

  Widget _buildFullNameRow() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: _fullNameController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.account_circle,
            color: Colors.blue,
          ),
          labelText: 'Full Name'
        ),
      ),
    );
  }

  Widget _buildEmailRow() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          prefixIcon: Icon(
            Icons.email,
            color: Colors.blue,
          ),
          labelText: 'E-mail'
        ),
      ),
    );
  }

  Widget _buildPasswordRow() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: _passwordController,
        keyboardType: TextInputType.text,
        obscureText: true,
        decoration: const InputDecoration(
          prefixIcon: Icon(
            Icons.lock,
            color: Colors.blue,
          ),
          labelText: 'Password',
        ),
      ),
    );
  }

  Widget _buildConfirmPasswordRow() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: _confirmPasswordController,
        keyboardType: TextInputType.text,
        obscureText: true,
        decoration: const InputDecoration(
          prefixIcon: Icon(
            Icons.lock,
            color: Colors.blue,
          ),
          labelText: 'Confirm Password',
        ),
      ),
    );
  }

  Widget _buildRegisterAsAnAttendeeButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 40),
            child: Container(
              height: 1.4 * (MediaQuery.of(context).size.height / 20),
              width: 5 * (MediaQuery.of(context).size.width / 10),
              margin: EdgeInsets.only(bottom: 20),
              child: RaisedButton(
                elevation: 5.0,
                color: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                onPressed: () {
                  _submitAttendeeForm();
                },
                child: Text(
                  "Register as an Attendee",
                  style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 1.5,
                    fontSize: MediaQuery.of(context).size.height / 60,
                  ),
                ),
              ),
            ))
      ],
    );
  }

  Widget _buildRegisterAsAnOrganizerButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 0),
            child: Container(
              height: 1.4 * (MediaQuery.of(context).size.height / 20),
              width: 5 * (MediaQuery.of(context).size.width / 10),
              margin: EdgeInsets.only(bottom: 20),
              child: RaisedButton(
                elevation: 5.0,
                color: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                onPressed: () {
                  _submitOrganizerForm();
                },
                child: Text(
                  "Register as an Organizer",
                  style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 1.5,
                    fontSize: MediaQuery.of(context).size.height / 60,
                  ),
                ),
              ),
            ))
      ],
    );
  }

  Widget _buildBacktoMainPageButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Container(
              height: (MediaQuery.of(context).size.height / 20),
              width: 3.5 * (MediaQuery.of(context).size.width / 10),
              margin: const EdgeInsets.only(bottom: 20.0),
              child: RaisedButton(
                elevation: 5.0,
                color: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Back to Main Page",
                  style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 1.5,
                    fontSize: MediaQuery.of(context).size.height / 70,
                  ),
                ),
              ),
            ))
      ],
    );
  }

  Widget _buildContainer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Register",
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height / 30,
                      ),
                    ),
                  ],
                ),
                _buildFullNameRow(),
                _buildEmailRow(),
                _buildPasswordRow(),
                _buildConfirmPasswordRow(),
                _buildRegisterAsAnAttendeeButton(),
                _buildRegisterAsAnOrganizerButton(),
                _buildBacktoMainPageButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _submitAttendeeForm() {
    StringBuffer errorMessageBuffer = new StringBuffer();

    if (_fullNameController.text == null) {
      errorMessageBuffer.writeln('Full Name not entered!');
    }
    if (_emailController.text == null) {
      errorMessageBuffer.writeln('Email not entered!');
    }
    if (_passwordController.text == null) {
      errorMessageBuffer.writeln('Password not entered!');
    }
    if (_confirmPasswordController.text == null) {
      errorMessageBuffer.writeln('Confirm password not entered!');
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      errorMessageBuffer.writeln('Confirmed password is different from password!');
    }

    if (errorMessageBuffer.isEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ConferenceSelectionOrganizer()),
        // TODO: CHANGE TO CONFERENCE SELECTION ATTENDEE
      );
    }
    else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessageBuffer.toString()),
        )
      );
    }
  }

  void _submitOrganizerForm() {
    StringBuffer errorMessageBuffer = new StringBuffer();

    if (_fullNameController.text == null) {
      errorMessageBuffer.writeln('Full Name not entered!');
    }
    if (_emailController.text == null) {
      errorMessageBuffer.writeln('Email not entered!');
    }
    if (_passwordController.text == null) {
      errorMessageBuffer.writeln('Password not entered!');
    }
    if (_confirmPasswordController.text == null) {
      errorMessageBuffer.writeln('Confirm password not entered!');
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      errorMessageBuffer.writeln('Confirmed password is different from password!');
    }

    if (errorMessageBuffer.isEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ConferenceSelectionOrganizer()),
      );
    }
    else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessageBuffer.toString()),
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Color(0xfff2f3f7),
        body: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildContainer(),
              ],
            )
          ],
        ),
      ),
    );
  }
}
