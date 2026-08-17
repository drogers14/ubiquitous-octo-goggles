import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_coffee_talk/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:geolocator/geolocator.dart';

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
  Position? _currentPosition;
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition();

    debugPrint(
      '📍 USER LOCATION: '
      '${position.latitude}, ${position.longitude}',
    );

    if (mounted) {
      setState(() {
        _currentPosition = position;
      });
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile() {
    final user = FirebaseAuth.instance.currentUser!;

    return FirebaseFirestore.instance
        .collection('userProfile')
        .doc(user.uid)
        .get();
  }

  Widget _getData(Map<String, dynamic> profile) {
    final name = profile['name'] ?? 'Unknown User';
    final imageUrl = profile['imageUrl'] ?? '';
    final username = profile['username'] ?? '';
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('journal-entry')
          .snapshots(),
      builder: (_, snapshot) {
        if (snapshot.hasError) return Text('Error = ${snapshot.error}');

        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final data = docs[i].data();

              double? distanceMiles;

              if (_currentPosition != null &&
                  data['latitude'] != null &&
                  data['longitude'] != null) {
                final double postLatitude = (data['latitude'] as num)
                    .toDouble();

                final double postLongitude = (data['longitude'] as num)
                    .toDouble();

                final double distanceMeters = Geolocator.distanceBetween(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                  postLatitude,
                  postLongitude,
                );

                distanceMiles = distanceMeters / 1609.344;
              }
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: imageUrl.isNotEmpty
                          ? NetworkImage(imageUrl)
                          : null,
                      child: imageUrl.isEmpty ? const Icon(Icons.person) : null,
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '@$username',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              if (distanceMiles != null) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '· ${distanceMiles.toStringAsFixed(2)} mi away',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                data['coffee-shop-name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                data['order-item'],
                                style: TextStyle(color: Colors.blue),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '·\$ ${data['price']}',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          StarRating(
                            rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
                            filledIcon: Icons.coffee,
                            halfFilledIcon: Icons.coffee_outlined,
                            emptyIcon: Icons.coffee_outlined,
                            color: AppColors
                                .limeCream, // Color for filled and half-filled icons
                            borderColor: Colors.grey, // Color for empty icons
                          ),
                          Text(data['review'], style: TextStyle(fontSize: 16)),

                          const SizedBox(height: 12),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Icon(
                                Icons.chat_bubble_outline,
                                color: Colors.grey,
                              ),
                              // Icon(Icons.repeat, color: Colors.grey),
                              Icon(Icons.favorite_border, color: Colors.grey),
                              // Icon(Icons.emoji_nature, color: Colors.grey),
                              Icon(Icons.share_outlined, color: Colors.grey),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: getUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('User profile not found'));
        }

        final profile = snapshot.data!.data()!;

        return _getData(profile);
      },
    );
  }
}
