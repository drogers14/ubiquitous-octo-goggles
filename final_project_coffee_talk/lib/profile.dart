import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final user = FirebaseAuth.instance.currentUser!;

  Future<DocumentSnapshot<Map<String, dynamic>>> getProfile() {
    return FirebaseFirestore.instance
        .collection('userProfile')
        .doc(user.uid)
        .get();
  }
Widget _getMostRecentPosts(){
  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
  stream: FirebaseFirestore.instance
      .collection('journal-entry')
      .where('userId', isEqualTo: user.uid)
.orderBy('createdAt', descending: true)
.limit(5)
      .snapshots(),
      
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }

    if (snapshot.hasError) {
        debugPrint('RECENT POSTS ERROR: ${snapshot.error}');

      return Text('Error: ${snapshot.error}');
    }

    final posts = snapshot.data?.docs ?? [];

    if (posts.isEmpty) {
      return const Text('No recent activity');
    }

    return Column(
      children: posts.map((doc) {
        final data = doc.data();

        return ListTile(
          title: Text(data['coffee-shop-name'] ?? ''),
          subtitle: Text(data['review'] ?? ''),
        );
      }).toList(),
    );
  },
);
}
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: getProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('Profile not found'));
        }

        final profile = snapshot.data!.data()!;

        final imageUrl = profile['imageUrl'] ?? '';
        final name = profile['name'] ?? 'Unknown User';
        final username = profile['username'] ?? '';

        return Column(
          children: [
            const SizedBox(height: 30),
            CircleAvatar(
              radius: 50,
              backgroundImage: profile['imageUrl'].isNotEmpty
                  ? NetworkImage(imageUrl)
                  : null,
              child: imageUrl.isEmpty
                  ? const Icon(Icons.person, size: 50)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              '@$username',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            _getMostRecentPosts(),
          ],
        );
      },
    );
  }
}
