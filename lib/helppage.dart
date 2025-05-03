import 'package:currensee/about.dart';
import 'package:currensee/components/bottom_navbar.dart';
import 'package:currensee/faqs.dart';
import 'package:currensee/screens/contactus.dart';
import 'package:currensee/userguide.dart';
import 'package:flutter/material.dart';
import 'package:currensee/components/my_appbar.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
     bool notificationsEnabled = false;
 


  @override
  Widget build(BuildContext context) {
    return Scaffold( backgroundColor: Colors.white,
      appBar: CustomAppBar(
        notificationsEnabled: notificationsEnabled,
         title: "Help Center",
        onToggleNotifications: () {
          setState(() {
            notificationsEnabled = !notificationsEnabled;
          });
        },
      ),
      drawer: CustomDrawer(
        // notificationsEnabled: notificationsEnabled,
        // onNotificationsChanged: (bool value) {
        //   setState(() {
        //     notificationsEnabled = value;
        //   });
        // },
      ),  body:
       SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25),
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
                onTap: () {
                   Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) =>  const ContactScreen()),);
                },
              ),
            ],
          ),
        ),
      ),
bottomNavigationBar: BottomNavBar(currentIndex: 0), // Home
    );
  }
}
