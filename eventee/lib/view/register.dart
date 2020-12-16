import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eventee/model/role.dart';
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
            labelText: 'Full Name'),
        maxLength: 300,
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
            prefixIcon: const Icon(
              Icons.email,
              color: Colors.blue,
            ),
            labelText: 'E-mail'),
        maxLength: 300,
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
          prefixIcon: const Icon(
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
        ));
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
                  fontSize: 22.0,
                ),
              ),
            ),
            _buildFullNameRow(),
            _buildEmailRow(),
            _buildPasswordRow(),
            _buildConfirmPasswordRow(),
            _buildRegisterButton(
                text: 'Register as Attendee', onPressed: _submitAttendeeForm),
            _buildRegisterButton(
                text: 'Register as Organizer', onPressed: _submitOrganizerForm),
            _buildBackButton(),
          ],
        ),
      ),
    );
  }

  void _submitForm(Role role) async {
    StringBuffer errorMessageBuffer = new StringBuffer();

    if (_fullNameController.text.isEmpty) {
      errorMessageBuffer.writeln('Full Name not entered!');
    }
    if (_emailController.text.isEmpty) {
      errorMessageBuffer.writeln('Email not entered!');
    }
    if (_passwordController.text.isEmpty) {
      errorMessageBuffer.writeln('Password not entered!');
    }
    if (_confirmPasswordController.text.isEmpty) {
      errorMessageBuffer.writeln('Confirm password not entered!');
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      errorMessageBuffer
          .writeln('Confirmed password is different from password!');
    }

    UserCredential userCredential;

    if (errorMessageBuffer.isEmpty) {
      try {
        userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _emailController.text,
                password: _passwordController.text);

        userCredential.user
            .updateProfile(displayName: _fullNameController.text);
      } on FirebaseAuthException catch (ex) {
        switch (ex.code) {
          case 'email-already-in-use':
            errorMessageBuffer.writeln('Email already in use.');
            break;
          case 'invalid-email':
            errorMessageBuffer.writeln('An invalid email was provided.');
            break;
          case 'weak-password':
            errorMessageBuffer.writeln('The provided password is too weak.');
            break;
          default:
            errorMessageBuffer.writeln('An error occurred when registering.');
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
              ));
    } else {
      FirebaseFirestore.instance.collection('users').add({
        'uid': userCredential.user.uid,
        'role': role.index,
      });

      print('Authentication!');
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
