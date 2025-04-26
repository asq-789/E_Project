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
          const DrawerHeader(
  decoration: BoxDecoration(color: themeColor),
  child: Center(
    child: Text(
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
  ),
),

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
          SwitchListTile(
            secondary: const Icon(Icons.notifications, color: themeColor),
            title: const Text('Notifications'),
            value: notificationsEnabled,
            onChanged: onNotificationsChanged,
          ),
          _divider(),
          _drawerItem(
            icon: Icons.help,
            text: 'Help Center',
            context: context,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HelpPage())),
          ),
          _divider(),
          _drawerItem(
            icon: Icons.logout,
            text: 'Logout',
            context: context,
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.restorablePopAndPushNamed(context, "/login");
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
    return const Divider( height: 1);
  }
}
