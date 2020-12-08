import 'package:flutter/material.dart';
import 'package:eventee/view/select_conference.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Widget _buildEmailRow() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
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
      child: TextField(
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

  Widget _buildLoginButton({String text, void Function() onPressed}) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: RaisedButton(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        elevation: 5.0,
        color: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBacktoMainPageButton() {
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
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            "Back",
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Login",
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height / 30,
                ),
              ),
            ),
            _buildEmailRow(),
            _buildPasswordRow(),
            _buildLoginButton(text: "Login as Attendee", onPressed: _submitAttendeeForm),
            _buildLoginButton(text: "Login as Organizer", onPressed: _submitOrganizerForm),
            _buildBacktoMainPageButton(),
          ],
        ),
      ),
    );
  }

  void _submitAttendeeForm() async {
    StringBuffer errorMessageBuffer = new StringBuffer();
    FirebaseAuth auth = FirebaseAuth.instance;

    if (_emailController.text.isEmpty) {
      errorMessageBuffer.writeln('Email not entered!');
    }
    if (_passwordController.text.isEmpty) {
      errorMessageBuffer.writeln('Password not entered!');
    }

    if (errorMessageBuffer.isEmpty) {
      try {
        UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text
        );

        // TODO: Check if user is attendee

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ConferenceSelectionOrganizer()),
          // TODO: CHANGE TO CONFERENCE SELECTION ATTENDEE
        );
      }
      on FirebaseAuthException catch (ex) {
        switch (ex.code) {
          case 'user-not-found':
            errorMessageBuffer.writeln('No user found for that email.');
            break;
          case 'wrong-password':
            errorMessageBuffer.writeln('Wrong password provided for that user.');
            break;
          case 'user-disabled':
            errorMessageBuffer.writeln('The account for that email has been disabled.');
            break;
          case 'invalid-email':
            errorMessageBuffer.writeln('An invalid email was provided.');
            break;
          default:
            errorMessageBuffer.writeln('An error occurred when logging in.');
            break;
        }
      }
    }

    if (errorMessageBuffer.isNotEmpty) {
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

    if (_emailController.text == null) {
      errorMessageBuffer.writeln('Email not entered!');
    }
    if (_passwordController.text == null) {
      errorMessageBuffer.writeln('Password not entered!');
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
