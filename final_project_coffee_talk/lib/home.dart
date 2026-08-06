import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Create a Form widget.
class CustomHomePage extends StatefulWidget {
  const CustomHomePage({super.key});

  @override
  HomePageState createState() {
    return HomePageState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class HomePageState extends State<CustomHomePage> {
//   Future<Widget> _get_data() async {
//   StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//   stream: FirebaseFirestore.instance.collection('DriverList').snapshots(),
//   builder: (_, snapshot) {
//     if (snapshot.hasError) return Text('Error = ${snapshot.error}');

//     if (snapshot.hasData) {
//       final docs = snapshot.data!.docs;
//       return ListView.builder(
//         itemCount: docs.length,
//         itemBuilder: (_, i) {
//           final data = docs[i].data();
//           return ListTile(
//             title: Text(data['name']),
//             subtitle: Text(data['phone']),
//           );
//         },
//       );
//     }

//     return Center(child: CircularProgressIndicator());
//   },
  
// );
//   }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(
                  'https://webstockreview.net/images/male-clipart-professional-man-3.jpg',
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Text(
                          'John Doe',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 6),
                        Text('@JohnDoe', style: TextStyle(color: Colors.grey)),
                        SizedBox(width: 6),
                        Text('· 2h', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    Row(
                      children: const [
                        Text(
                          'Coffee Shop Name',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Drink/Item',
                          style: TextStyle(color: Colors.blue),
                        ),
                        SizedBox(width: 6),
                        Text('· Price', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 8),

                    const Text(
                      'Fair Coffee Review! '
                      'Really enjoying learning widgets and layouts. ',
                      style: TextStyle(fontSize: 16),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Icon(Icons.chat_bubble_outline, color: Colors.grey),
                        // Icon(Icons.repeat, color: Colors.grey),
                        Icon(Icons.favorite_border, color: Colors.grey),
                        Icon(Icons.bar_chart, color: Colors.grey),
                        Icon(Icons.share_outlined, color: Colors.grey),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
