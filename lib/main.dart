import 'package:currensee/firebase_options.dart';
import 'package:currensee/screens/loaderpage.dart';
import 'package:currensee/screens/TrendsPage.dart';
import 'package:currensee/screens/currency_list.dart';
import 'package:currensee/screens/currencyhistory.dart';
import 'package:currensee/screens/home.dart';
import 'package:currensee/screens/login.dart';
import 'package:currensee/screens/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,  
  );
 final SharedPreferences prefs = await SharedPreferences.getInstance();

  
  if (!prefs.containsKey('notificationsEnabled')) {
    await prefs.setBool('notificationsEnabled', true);
  }

   bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
  runApp(MyApp(isLoggedIn: isLoggedIn));

  }

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key ,required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Currensee',
      theme: ThemeData(primarySwatch: Colors.indigo),
    home:  isLoggedIn ? HomeScreen() : Login(),
 initialRoute: '/Currensee',
    routes: {
     '/Currensee': (context) => Currensee(),
       '/login': (context) =>  isLoggedIn ? HomeScreen()  : Login(),
        '/signup': (context) => Signup(),
        '/currencies':(context)=> isLoggedIn ? CurrencyList() : Login(),
          '/help': (context) => HomeScreen(),   
           '/exchangeratehistory':(context) => isLoggedIn ? Currencyhistory() : Login(),
           '/Trend':(context) => Trendspage(),
              
          

   } );
  }
}
