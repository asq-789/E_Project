import 'package:currensee/components/bottom_navbar.dart';

import 'package:flutter/material.dart';
import 'package:currensee/components/my_appbar.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {

  bool notificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        notificationsEnabled: notificationsEnabled,
        title: "About Us",
        onToggleNotifications: () {
          setState(() {
            notificationsEnabled = !notificationsEnabled;
          });
        },
      ),
      drawer: CustomDrawer(
        notificationsEnabled: notificationsEnabled,
        onNotificationsChanged: (bool value) {
          setState(() {
            notificationsEnabled = value;
          });
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
          
            Center(
              child: Image.asset(
                'public/assets/images/logogreen.png',
                width: 120,
                height: 120,
              ),
            ),
            const SizedBox(height: 18),
          
            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Welcome to Currensee!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF388E3C), 
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "We are a dedicated team working towards providing accurate and up-to-date currency conversion information to help you make informed decisions about currency exchange.\n\n"
                    "At Currensee, we aim to offer a user-friendly experience with real-time exchange rates, historical data, and easy conversion between a variety of currencies. Whether you are a frequent traveler or a business professional, our app ensures you have the latest information on hand, whenever you need it.\n\n"
                    "Our mission is to make currency conversion simple and accessible to everyone. We are continuously improving the app to offer you the best experience possible.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 0),
    );
  }
}
