import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:image_picker/image_picker.dart';

// Create a Form widget.
class MyCustomForm extends StatefulWidget {
  const MyCustomForm({super.key});

  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class MyCustomFormState extends State<MyCustomForm> {
    final picker = ImagePicker();

  late Future<File> _imageFile;
  final List<File> _imagesTaken = [];
  void _getImage() async {
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = Future.value(File(pickedFile.path));
        _imagesTaken.add(File(pickedFile.path));
      });
print("Length: ${_imagesTaken.length}");

  for (final image in _imagesTaken) {
    print(image.path);
  }
      return;
    }
    setState(() {
      _imageFile = Future.error("uh oh");
    });
  }
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  final String _coffeShopName = '';
  final String _coffeeOrder = '';
  final double _price = 0.0;
  final String _reviewEntry = '';
  double rating = 3.5;
  int starCount = 5;

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            decoration: InputDecoration(
          
          // Label for the name field
          labelText: 'Shop Name',
          
          // Border style for the text field
          border: OutlineInputBorder(), 
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.green,
              width: 2.0,
            ), // Border color when focused
          ),
        ),
            // The validator receives the text that the user has entered.
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
           TextFormField(
            decoration: InputDecoration(
                      labelText: 'Drink',
            ),

           ),
                TextFormField(
            decoration: InputDecoration(
                      labelText: 'Price',
            ),

           ),
           FloatingActionButton(
            onPressed: _getImage,
            heroTag: null,
            tooltip: 'Take Photo',
            child: const Icon(Icons.camera_alt),
          ),
          StarRating(
              size: 40.0,
              rating: rating,
              color: Colors.orange,
              borderColor: Colors.grey,
              allowHalfRating: true,
              starCount: starCount,
              onRatingChanged: (rating) => setState(() {
                this.rating = rating;
              }),
            ),
          
          SizedBox(height: 20),
          Text(
            "Your rating is: $rating",
            style: TextStyle(fontSize: 30.0),
          ),
                  TextFormField(
            decoration: InputDecoration(
                      labelText: 'Review',
            ),

           ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ElevatedButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Processing Data')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}