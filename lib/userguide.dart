import 'package:currensee/components/bottom_navbar.dart';
import 'package:currensee/faqs.dart';
import 'package:currensee/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:currensee/components/my_appbar.dart';

class UserGuidePage extends StatefulWidget {
  const UserGuidePage({super.key});

  @override
  State<UserGuidePage> createState() => _UserGuidePageState();
}

class _UserGuidePageState extends State<UserGuidePage> {
  int _selectedIndex = 0;
  bool notificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background safed clean
      appBar: CustomAppBar(
        notificationsEnabled: notificationsEnabled,
        title: "User Guide",
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
        child: Padding(
          padding: const EdgeInsets.all(25), 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
            
                    Center(
                      child: Text(
                        "Explore the Features of Currensee",
                      
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF388E3C),
                          shadows: [
                            Shadow(
                              offset: Offset(2, 2),
                              blurRadius: 3,
                              color: const Color.fromARGB(66, 114, 114, 113),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 4),
                    Center(
                      child: Text(
                        "Your go-to app for seamless currency conversion.",
                        style: TextStyle(
                         fontSize: 15, fontStyle: FontStyle.italic, color: Colors.black54
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
           
                  
               
              SizedBox(height: 25),
              GuideCard(
                title: "Currency Conversion",
                description:
                    "Easily convert currencies by selecting the 'From' and 'To' currencies and entering the amount. Press 'Convert' to see the result instantly.",
              ),
              GuideCard(
                title: "Swap Currencies",
                description:
                    "Tap the swap icon between the currency dropdowns to quickly swap 'From' and 'To' currencies.",
              ),
              GuideCard(
                title: "Notifications",
                description:
                    "Enable notifications in settings to stay updated on significant exchange rate changes.",
              ),
              GuideCard(
                title: "Settings & Preferences",
                description:
                    "Customize your preferences, manage notifications, and access your profile and conversion history.",
              ),
              GuideCard(
                title: "Help & Support",
                description:
                    "Visit the Help Center from settings for FAQs or contact customer support directly for assistance.",
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 0),
    );
  }
}

class GuideCard extends StatelessWidget {
  final String title;
  final String description;

  const GuideCard({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Color(0xFF388E3C).withOpacity(0.3),
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF388E3C),
              ),
            ),
            SizedBox(height: 10),
            Text(
              description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
