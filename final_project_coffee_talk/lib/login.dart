import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
    if(kIsWeb){
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope(
        'https://www.googleapis.com/auth/contacts.readonly',
      );
      googleProvider.setCustomParameters({'login_hint': 'user@example.com'});
      return await FirebaseAuth.instance.signInWithPopup(googleProvider);
    }
    final GoogleSignInAccount? _googleUser = await GoogleSignIn.instance
    .authenticate();

    final GoogleSignInAuthentication googleAuth = _googleUser!.authentication;

    final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);

    return await FirebaseAuth.instance.signInWithCredential(credential);
   
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
    }
    return widgets;
  }
}
