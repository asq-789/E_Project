import 'package:currensee/faqs.dart';
import 'package:currensee/screens/home.dart';
import 'package:flutter/material.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  int _selectedIndex = 0;

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
      appBar: AppBar(
        title: Text("About Us", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF388E3C),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // You can open the settings page or menu
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF388E3C),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: "Convert",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Charts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "Currency List",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_mail),
            label: "Contact Us",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: "Feedback",
          ),
        ],
      ),
    );
  }
}
