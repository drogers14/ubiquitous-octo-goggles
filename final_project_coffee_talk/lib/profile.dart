import 'package:flutter/material.dart';
// Create a Form widget.
class MyCustomProfile extends StatefulWidget {
  const MyCustomProfile({super.key});

  @override
  MyCustomProfileState createState() {
    return MyCustomProfileState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class MyCustomProfileState extends State<MyCustomProfile> {

  @override
  Widget build(BuildContext context) {
    return Column(
    children:[ Card(
          shadowColor: Colors.transparent,
          margin: const .all(8.0),
          child: SizedBox.expand(
            child: Center(
              child: Text('Home page', ),
            ),
          ),
        ),
    ],
 );
 }
}
