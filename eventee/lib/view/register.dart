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
      child: TextField(
        controller: _fullNameController,
        decoration: const InputDecoration(
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

  Widget _buildRegisterButton({String text, void Function() onPressed}) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: RaisedButton(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        elevation: 5.0,
        color: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15.0,
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20.0),
        child: RaisedButton(
          elevation: 5.0,
          color: Colors.blueGrey[600],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Back',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.0,
            ),
          ),
        ),
      )
    );
  }

  Widget _buildContainer() {
    return ClipRRect(
      borderRadius: const BorderRadius.all(
        Radius.circular(20.0),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Register",
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
            _buildFullNameRow(),
            _buildEmailRow(),
            _buildPasswordRow(),
            _buildConfirmPasswordRow(),
            _buildRegisterButton(text: 'Register as Attendee', onPressed: _submitAttendeeForm),
            _buildRegisterButton(text: 'Register as Organizer', onPressed: _submitOrganizerForm),
            _buildBackButton(),
          ],
        ),
      ),
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
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: SingleChildScrollView(
          child: _buildContainer(),
        ),
      ),
    );
  }
}
