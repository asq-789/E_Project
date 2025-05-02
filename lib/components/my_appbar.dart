import 'package:currensee/screens/login.dart';
import 'package:currensee/screens/rate_alert.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currensee/screens/marketnews.dart';
import 'package:currensee/screens/profile.dart';
import 'package:currensee/screens/history.dart';
import 'package:currensee/screens/liked_currencies.dart';
import 'package:currensee/helppage.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final bool notificationsEnabled;
  final VoidCallback onToggleNotifications;
  final String title;
 // bool notificationsEnabled = true;

  const CustomAppBar({
    super.key,
    required this.notificationsEnabled,
    required this.onToggleNotifications,
    required this.title,
  });

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  String baseCurrency = "";

  @override
  void initState() {
    super.initState();
    _fetchBaseCurrency();
  }

  Future<void> _fetchBaseCurrency() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        baseCurrency = doc['baseCurrency'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      backgroundColor: const Color(0xFF388E3C),
      title: Text(widget.title, style: const TextStyle(color: Colors.white)),
actions: [
  IconButton(
    icon: const Icon(Icons.trending_up, color: Colors.white),
    onPressed: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const MarketNewsPage()));
    },
  ),
  // IconButton(
  //   icon: const Icon(Icons.notifications, color: Colors.white),
  //   onPressed: widget.onToggleNotifications,
  // ),
Center(
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFFA5D6A7), 
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.6), 
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          baseCurrency,
          style: const TextStyle(
            color: Colors.white,
                    fontStyle: FontStyle.italic,

            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    ),
  ),
),
],
  );
  }
}

class CustomDrawer extends StatelessWidget {
  final bool notificationsEnabled;
  final ValueChanged<bool> onNotificationsChanged;

  const CustomDrawer({
    super.key,
    required this.notificationsEnabled,
    required this.onNotificationsChanged,
  });

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF388E3C);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // DrawerHeader with logo
          const DrawerHeader(
            decoration: BoxDecoration(color: themeColor),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Image
                // Image.asset(
                //    'public/assets/images/bg.png',
                // ),
                  SizedBox(height: 10), // Space between logo and text
                  Text(
                    'Currensee',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 3.0,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Drawer items
          _drawerItem(
            icon: Icons.person,
            text: 'Profile',
            context: context,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Profile())),
          ),
          _divider(),
          _drawerItem(
            icon: Icons.history,
            text: 'History',
            context: context,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => History())),
          ),
          _divider(),
          _drawerItem(
            icon: Icons.favorite,
            text: 'Liked Currencies',
            context: context,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LikedCurrrencies())),
          ),
          _divider(),
          _drawerItem(
            icon: Icons.arrow_circle_right_sharp,
            text: 'Check Alerts ',
            context: context,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RateAlerts())),
          ),
          _divider(),
          _drawerItem(
            icon: Icons.help,
            text: 'Help Center',
            context: context,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HelpPage())),
          ),_divider(),
SwitchListTile(
  title: const Text('Enable Notifications'),
  secondary: const Icon(Icons.notifications_active, color: Color(0xFF388E3C)),
  value: notificationsEnabled,
  activeColor: Color(0xFF388E3C),        // Thumb color when ON
  activeTrackColor: Color(0xFFC8E6C9),   // Track color when ON
  inactiveThumbColor: Colors.grey,       // Thumb color when OFF
  inactiveTrackColor: Colors.black26,    // Track color when OFF
  onChanged: onNotificationsChanged,
),


_divider(),
          _divider(),
          _drawerItem(
            icon: Icons.logout,
            text: 'Logout',
            context: context,
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 10,
                    title: Text(
                      'Logout Confirmation',
                      style: TextStyle(color: themeColor),
                    ),
                    content: Text('Are you sure you want to Logout?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: themeColor),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          FirebaseAuth.instance.signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Login()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF388E3C),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String text,
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF388E3C)),
        title: Text(text),
        onTap: onTap,
      ),
    );
  }

  Widget _divider() {
    return const Divider(height: 1);
  }
}
