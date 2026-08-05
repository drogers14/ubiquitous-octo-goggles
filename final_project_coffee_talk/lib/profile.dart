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
  children: [
    Card(
      margin: const EdgeInsets.all(8.0),
      child: const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(
          child: Text('Profile'),
        ),
      ),
    ),
  ],
);
 }
}
