import 'package:eventee/view/utils/generic_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:eventee/view/main_screen.dart';
import 'package:eventee/view/select_conference.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        Widget home;

        if (snapshot.connectionState == ConnectionState.done) {
          //home = MainScreenPage();
          home = ConferenceSelectionOrganizer();
        } else {
          home = Scaffold(body: GenericLoadingIndicator());
        }

        return MaterialApp(
          title: 'Eventee',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: home,
        );
      },
    );
  }
}
