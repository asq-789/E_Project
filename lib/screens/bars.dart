import 'package:currensee/helppage.dart';
import 'package:currensee/screens/Charts.dart';
import 'package:currensee/screens/contactus.dart';
import 'package:currensee/screens/currency_list.dart';
import 'package:currensee/screens/feedback.dart';
import 'package:currensee/screens/home.dart';
import 'package:currensee/screens/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Bars extends StatefulWidget {
  const Bars({super.key});

  @override
  State<Bars> createState() => _BarsState();
}

class _BarsState extends State<Bars> {
  int _selectedIndex = 0;
  bool notificationsEnabled = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (_selectedIndex) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const Charts()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const CurrencyList()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactScreen()));
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const FeedbackScreen()));
        break;
    }
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Profile'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
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
                      leading: Icon(Icons.favorite_border),
                      title: Text('Liked Currencies'),
                      onTap: () {
                        Navigator.pop(context);
                        print("Liked Currencies clicked");
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
                    ),
                    ListTile(
                      leading: Icon(Icons.help),
                      title: Text('Help Center'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => HelpPage()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Logout'),
                      onTap: () async {
                        Navigator.pop(context);
                        await FirebaseAuth.instance.signOut();
                        Navigator.restorablePopAndPushNamed(context, "/login");
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Appbar
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF388E3C),
        title: Text("Currensee", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.trending_up, color: Colors.white),
            onPressed: () {
              print("Market Trends Clicked");
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              setState(() {
                notificationsEnabled = !notificationsEnabled;
              });
            },
          ),
          // Removed the like (favorite_border) icon
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
      //bottom bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF388E3C),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: "Convert"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Charts"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Currency List"),
          BottomNavigationBarItem(icon: Icon(Icons.contact_mail), label: "Contact Us"),
          BottomNavigationBarItem(icon: Icon(Icons.feedback), label: "Feedback"),
        ],
      ),
    );
  }
}
