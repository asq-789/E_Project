import 'package:currensee/faqs.dart';
import 'package:currensee/screens/home.dart';
import 'package:flutter/material.dart';

class UserGuidePage extends StatefulWidget {
  const UserGuidePage({super.key});

  @override
  State<UserGuidePage> createState() => _UserGuidePageState();
}

class _UserGuidePageState extends State<UserGuidePage> {
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
        title: Text("User Guide", style: TextStyle(color: Colors.white)),
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
            // Guide Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Welcome to the Currensee User Guide! Here you will find instructions on how to use the app.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "1. **Currency Conversion:**\n"
                "You can easily convert currencies by selecting the 'From' and 'To' currencies and entering the amount. Then, press 'Convert'. The result will be shown instantly.\n\n"
                "2. **Swap Currencies:**\n"
                "To swap the 'From' and 'To' currencies, tap the swap icon between the two currency dropdowns.\n\n"
                "3. **Notifications:**\n"
                "You can enable notifications in the settings to get notified about significant changes in the exchange rate.\n\n"
                "4. **Settings & Preferences:**\n"
                "Customize your preferences, including turning notifications on/off and accessing your profile or history.\n\n"
                "5. **Help & Support:**\n"
                "Access the Help Center from the settings menu to get answers to common questions or contact customer support for further assistance.",
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 30),
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
