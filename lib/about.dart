import 'package:currensee/components/bottom_navbar.dart';
import 'package:currensee/faqs.dart';
import 'package:currensee/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:currensee/components/my_appbar.dart';
class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  int _selectedIndex = 0;
   bool notificationsEnabled = false;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to the corresponding page based on selected index
    switch (_selectedIndex) {
      case 0:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const HomeScreen())); // Home Screen
        break;
      case 1:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const FaqPage())); // FAQs Page
        break;
      case 2:
        // Add your destination page for Currency List
        break;
      case 3:
        // Add your destination page for Contact Us
        break;
      case 4:
        // Add your destination page for Feedback
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      ), body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            // App Logo in Center
            Center(
              child: Image.asset(
              'public/assets/images/logogreen.png', 
                width: 120,
                height: 120,
              ),
            ),
            const SizedBox(height: 40),
            // About Us Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Welcome to Currensee! We are a dedicated team working towards providing accurate and up-to-date currency conversion information to help you make informed decisions about currency exchange.\n\n"
                "At Currensee, we aim to offer a user-friendly experience with real-time exchange rates, historical data, and easy conversion between a variety of currencies. Whether you are a frequent traveler or a business professional, our app ensures you have the latest information on hand, whenever you need it.\n\n"
                "Our mission is to make currency conversion simple and accessible to everyone. We are continuously improving the app to offer you the best experience possible.",
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
 bottomNavigationBar: BottomNavBar(),
    );
  }
}
