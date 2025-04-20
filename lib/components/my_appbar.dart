import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:currensee/screens/marketnews.dart';
import 'package:currensee/screens/profile.dart';
import 'package:currensee/screens/history.dart';
import 'package:currensee/screens/liked_currencies.dart';
import 'package:currensee/helppage.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool notificationsEnabled;
  final VoidCallback onToggleNotifications;
  

  const CustomAppBar({
    super.key,
    required this.notificationsEnabled,
    required this.onToggleNotifications,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      backgroundColor: const Color(0xFF388E3C),
      title: const Text("Currensee", style: TextStyle(color: Colors.white)),
      actions: [
        IconButton(
          icon: const Icon(Icons.trending_up, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MarketNewsPage()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: onToggleNotifications,
        ),
      ],
    );
  }
}

class CustomDrawer extends StatelessWidget {
  //  bool notificationsEnabled = false;

  final bool notificationsEnabled;
  final ValueChanged<bool> onNotificationsChanged;

  const CustomDrawer({
    super.key,
    required this.notificationsEnabled,
    required this.onNotificationsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF388E3C),
            ),
            child: Center(
              child: Text(
                'Currensee',
                style: TextStyle(color: Colors.white, fontSize: 26),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('History'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => History()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Liked Currencies'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => LikedCurrrencies()));
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            value: notificationsEnabled,
            onChanged: onNotificationsChanged,
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help Center'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => HelpPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.restorablePopAndPushNamed(context, "/login");
            },
          ),
        ],
      ),
    );
  }
}
