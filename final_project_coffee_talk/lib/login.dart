import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_coffee_talk/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

const List<String> scopes = <String>[
  // 'https://www.googleapis.com/auth/contracts.readonly',
];

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GoogleSignInAccount? _googleUser;

   Future<UserCredential> signInWithGoogle() async {
  if (kIsWeb) {
    final GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider.addScope(
      'https://www.googleapis.com/auth/contacts.readonly',
    );

    final UserCredential userCredential =
    await FirebaseAuth.instance.signInWithPopup(googleProvider);

final User? user = userCredential.user;

if (user != null) {
  await FirebaseFirestore.instance
      .collection('userProfile')
      .doc(user.uid)
      .set({
    'name': user.displayName ?? '',
    'email': user.email ?? '',
    'imageUrl': user.photoURL ?? '',
  }, SetOptions(merge: true));
}

    if (!mounted) return userCredential;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const MyApp(),
      ),
      (Route<dynamic> route) => false,
    );

    return userCredential;
  } else {
    final GoogleSignIn signIn = GoogleSignIn.instance;

    await signIn.initialize();

    _googleUser = await signIn.authenticate();

    final GoogleSignInAuthentication googleAuth =
        _googleUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    if (!mounted) return userCredential;

    setState(() {});

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const MyApp(),
      ),
      (Route<dynamic> route) => false,
    );

    return userCredential;
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _buildBody(),
        ),
      ),
    );
  }

  List<Widget> _buildBody() {
    List<Widget> widgets = [];
    if(_googleUser == null){
      widgets.add(
        ElevatedButton(
          onPressed: () async {
            await signInWithGoogle();
            },
      
      child: const Text ("Sign in with Google"),
      ),
      );
    }
    else{
      widgets.add(
        ListTile(leading: GoogleUserCircleAvatar(identity: _googleUser!),
        title: Text(_googleUser!.displayName ?? ""),
        subtitle: Text(_googleUser!.email),
        ),
      );
      widgets.add(Text(FirebaseAuth.instance.currentUser?.uid ?? ""));
      widgets.add(
        ElevatedButton(onPressed: () async {
          await FirebaseAuth.instance.signOut();
          await GoogleSignIn.instance.signOut();
          _googleUser = null;

          setState((){
          });
        }, 
        child: const Text("Sign Out"),
        ),
      );
    }
    return widgets;
  }
}
