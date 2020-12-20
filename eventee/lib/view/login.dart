
import 'package:eventee/model/role.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eventee/view/select_conference.dart';

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
        key: Key('email'),
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          prefixIcon: Icon(
            Icons.email,
            color: Colors.blue,
          ),
          labelText: 'E-mail'
        ),
        maxLength: 300,
      ),
    );
  }

  Widget _buildPasswordRow() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        key: Key('password'),
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
        key: Key(text),
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
                "Login",
                style: TextStyle(
                  fontSize: 22.0,
                ),
              ),
            ),
            _buildEmailRow(),
            _buildPasswordRow(),
            _buildLoginButton(text: "Login as Attendee", onPressed: _submitAttendeeForm),
            _buildLoginButton(text: "Login as Organizer", onPressed: _submitOrganizerForm),
            _buildBackButton(),
          ],
        ),
      ),
    );
  }

  void _submitForm(Role role) async {
    StringBuffer errorMessageBuffer = new StringBuffer();

    if (_emailController.text.isEmpty) {
      errorMessageBuffer.writeln('Email not entered!');
    }
    if (_passwordController.text.isEmpty) {
      errorMessageBuffer.writeln('Password not entered!');
    }

    UserCredential userCredential;

    if (errorMessageBuffer.isEmpty) {
      try {
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text
        );

        Query query = FirebaseFirestore.instance.collection('users')
            .where('uid', isEqualTo: userCredential.user.uid)
            .where('role', isEqualTo: role.index);
        
        await query.get()
            .then((snapshot) {
              if (snapshot.docs.isEmpty) {
                errorMessageBuffer.writeln('No user found for that email.');
              }
            })
            .catchError((error) => errorMessageBuffer.writeln('Error occurred while verifying credentials.'));
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
    else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ConferenceSelection(userCredential: userCredential, role: role)),
      );
    }
  }

  void _submitAttendeeForm() {
    _submitForm(Role.attendee);
  }

  void _submitOrganizerForm() {
    _submitForm(Role.organizer);
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
