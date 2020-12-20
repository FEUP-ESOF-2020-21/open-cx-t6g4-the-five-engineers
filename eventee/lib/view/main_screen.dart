import 'package:flutter/material.dart';
import 'package:eventee/view/login.dart';
import 'package:eventee/view/register.dart';

class MainScreenPage extends StatelessWidget {
  Widget _buildButton({String text, void Function() onPressed}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: RaisedButton(
          elevation: 5.0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          onPressed: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.blue,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
              image: AssetImage('assets/eventee_logo.png'),
            ),
            _buildButton(text: 'Login', onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage())
            )),
            _buildButton(text: 'Register', onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegisterPage())
            )),
          ],
        ),
      ),
    );
  }
}
