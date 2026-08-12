import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
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

  late Future<XFile> _imageFile;
  final List<XFile> _imagesTaken = [];
  Future<void> _getImage() async {
  final XFile? pickedFile = await picker.pickImage(
    source: ImageSource.camera,
  );

  if (pickedFile != null) {
    setState(() {
      _imagesTaken.add(pickedFile);
    });

    print("Length: ${_imagesTaken.length}");

    for (final image in _imagesTaken) {
      print(image.name);
    }
  }
}

Future<List<String>> _uploadImages(String entryId) async {
  final List<String> imageUrls = [];

  for (int i = 0; i < _imagesTaken.length; i++) {
    final XFile image = _imagesTaken[i];

    final Uint8List bytes = await image.readAsBytes();

    final Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('journal-images')
        .child(entryId)
        .child('${i}_${image.name}');

    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
    );

    await storageRef.putData(
      bytes,
      metadata,
    );

    final String downloadUrl =
        await storageRef.getDownloadURL();

    imageUrls.add(downloadUrl);
  }

  return imageUrls;
}

Future<Position?> _getLocation() async {
  bool serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

  if (!serviceEnabled) {
    return null;
  }

  LocationPermission permission =
      await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    return null;
  }

  return await Geolocator.getCurrentPosition();
}
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  String _coffeeShopName = '';
  String _coffeeOrder = '';
  double _price = 0.0;
  String _reviewEntry = '';

  Future<void> _submitForm() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  _formKey.currentState!.save();

  final User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You must be logged in to post.'),
      ),
    );
    return;
  }

  try {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Saving your coffee journal...'),
      ),
    );

    // Create the Firestore document first.
    final DocumentReference<Map<String, dynamic>> entryRef =
        FirebaseFirestore.instance
            .collection('journal-entry')
            .doc();

    // Get location.
    Position? position;

    try {
      position = await _getLocation();
      debugPrint(
        'Location: ${position?.latitude}, ${position?.longitude}',
      );
    } catch (e) {
      debugPrint('Location failed: $e');
    }

    // Save the journal entry immediately.
    await entryRef.set({
      'userId': user.uid,
      'coffee-shop-name': _coffeeShopName,
      'order-item': _coffeeOrder,
      'price': _price,
      'review': _reviewEntry,
      'rating': rating,
      'imageUrls': [],
      'latitude': position?.latitude,
      'longitude': position?.longitude,
      'createdAt': FieldValue.serverTimestamp(),
    });

    debugPrint('Firestore entry created: ${entryRef.id}');

    // Upload images AFTER the Firestore entry exists.
    if (_imagesTaken.isNotEmpty) {
      try {
        final List<String> imageUrls =
            await _uploadImages(entryRef.id);

        await entryRef.update({
          'imageUrls': imageUrls,
        });

        debugPrint('Images uploaded: $imageUrls');
      } catch (e) {
        debugPrint('Image upload failed: $e');
      }
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coffee journal posted! ☕'),
      ),
    );
  } catch (e, stackTrace) {
    debugPrint('JOURNAL SAVE ERROR: $e');
    debugPrint('$stackTrace');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Something went wrong: $e'),
      ),
    );
  }
}

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
          /* COFFEE SHOP */
          TextFormField(
            decoration: InputDecoration(
              icon: Icon(Icons.local_cafe),
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
            onSaved: (value) {
              // Save the entered email
              _coffeeShopName = value!;
            },
          ),
          /* DRINK ORDER */
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Drink',
              icon: Icon(Icons.local_cafe),
            ),
            onSaved: (value) {
              // Save the entered email
              _coffeeOrder = value!;
            },
          ),
          TextFormField(
  decoration: const InputDecoration(
    labelText: 'Price',
  ),
  keyboardType: const TextInputType.numberWithOptions(
    decimal: true,
  ),
  onSaved: (value) {
    _price = double.tryParse(value ?? '') ?? 0.0;
  },
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
          Text("Your rating is: $rating", style: TextStyle(fontSize: 30.0)),
          TextFormField(
            decoration: InputDecoration(labelText: 'Review'),
            onSaved: (value) {
              // Save the entered email
              _reviewEntry = value!;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ElevatedButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false otherwise.
                _submitForm();
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
