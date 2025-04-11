import 'package:currensee/firebase_options.dart';
import 'package:currensee/loaderpage.dart';
import 'package:currensee/screens/currency_list.dart';
import 'package:currensee/screens/home.dart';
import 'package:currensee/screens/login.dart';
import 'package:currensee/screens/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,  
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Currensee',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: Currensee(),
initialRoute: '/Currensee',
    routes: {
       '/Currensee': (context) => Currensee(),
       '/login': (context) =>  Login(),
        '/signup': (context) => Signup(),
       '/home':(context)=> HomeScreen(),
        '/currencies':(context)=> CurrencyList(),
   } );
  }
}
