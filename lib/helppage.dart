import 'package:currensee/about.dart';
import 'package:currensee/faqs.dart';
import 'package:currensee/screens/home.dart';
import 'package:currensee/userguide.dart';
import 'package:flutter/material.dart';


class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  int _selectedIndex = 0;
  bool notificationsEnabled = false;

  void _onItemTapped(int index) {
    if (index == 0) {
      // Navigate to HomeScreen (Convert Page)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.history),
                title: Text('History'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.notifications),
                title: Text('Notifications'),
                trailing: Switch(
                  value: notificationsEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      notificationsEnabled = value;
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    notificationsEnabled = !notificationsEnabled;
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.help),
                title: Text('Help Center'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Help & Support", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF388E3C),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              setState(() {
                notificationsEnabled = !notificationsEnabled;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Center(
              child: Image.asset(
                'public/assets/images/logogreen.png',
                width: 120,
                height: 120,
              ),
            ),
            const SizedBox(height: 40),
            ListTile(
              leading: Icon(Icons.question_answer, color: Color(0xFF388E3C)),
              title: Text("FAQs"),
              onTap: () {
                 Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FaqPage()),
      );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.menu_book, color: Color(0xFF388E3C)),
              title: Text("User Guide"),
              onTap: () { Navigator.pushReplacement(
        context,
                MaterialPageRoute(builder: (context) => const UserGuidePage()),

      );
                
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.info_outline, color: Color(0xFF388E3C)),
              title: Text("About Us"),
              onTap: () {
                Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) =>  const AboutUsPage()),);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.contact_support, color: Color(0xFF388E3C)),
              title: Text("Contact Support"),
              onTap: () {},
            ),
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
              icon: Icon(Icons.swap_horiz), label: "Convert"),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: "Charts"),
          BottomNavigationBarItem(
              icon: Icon(Icons.list), label: "Currency List"),
          BottomNavigationBarItem(
              icon: Icon(Icons.contact_mail), label: "Contact Us"),
          BottomNavigationBarItem(
              icon: Icon(Icons.feedback), label: "Feedback"),
        ],
      ),
    );
  }
}
