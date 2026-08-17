import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_coffee_talk/coffeeEntry.dart';
import 'package:final_project_coffee_talk/home.dart';
import 'package:final_project_coffee_talk/login.dart';
import 'package:final_project_coffee_talk/profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';

// https://coolors.co/65524d-817e9f-7fc29b-b5ef8a-d7f171
class AppColors {
  static const taupeGrey = Color(0xFF65524D);
  static const lavenderGrey = Color(0xFF817E9F);
  static const mutedTeal = Color(0xFF7FC29B);
  static const lightGreen = Color(0xFFB5EF8A);
  static const limeCream = Color(0xFFD7F171);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  // runApp(const MyApp());
  await dotenv.load();
  runApp(const MaterialApp(title: "Login Page", home: LoginPage()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
  
        colorScheme: .fromSeed(seedColor: AppColors.lightGreen),
      ),
      home: const MyHomePage(title: 'Coffee Talk'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
       
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
       
        title: Text(widget.title),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: AppColors.mutedTeal,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Badge(label: Text('2'), child: Icon(Icons.notifications_sharp)),
            label: 'Notifications',
          ),
          NavigationDestination(
            icon: Badge(child: Icon(Icons.add_outlined)),
            label: 'New Entry',
          ),
           NavigationDestination(
            icon: Icon(Icons.coffee),
            label: 'Profile',
          ),
        ],
      ),
       body: <Widget>[
        const CustomHomePage(),

                /// Notifications page
        const Padding(
          padding: .all(8.0),
          child: Column(
            children: <Widget>[
              Card(
                child: ListTile(
                  leading: Icon(Icons.notifications_sharp),
                  title: Text('Notification 1'),
                  subtitle: Text('This is a notification'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.notifications_sharp),
                  title: Text('Notification 2'),
                  subtitle: Text('This is a notification'),
                ),
              ),
            ],
          ),
        ),
const MyCustomForm(),
const MyCustomProfile(),
     ][currentPageIndex],

 
    );
  }
}
