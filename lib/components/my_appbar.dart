import 'dart:async';
import 'dart:convert';
import 'package:currensee/screens/login.dart';
import 'package:currensee/screens/rate_alert.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currensee/screens/marketnews.dart';
import 'package:currensee/screens/profile.dart';
import 'package:currensee/screens/history.dart';
import 'package:currensee/screens/liked_currencies.dart';
import 'package:currensee/helppage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
  String fromCurrency = 'USD';
  String toCurrency = 'PKR';
  double exchangeRate = 0.0;
  List<MapEntry<String, double>> filteredCurrencies = [];
  List<FlSpot> historicalDataPoints = [];
  Color themeColor = Colors.green;
  String selectedCurrency = '';
  TextEditingController searchController = TextEditingController();

  bool hasShownAlert = false;
  bool notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _fetchBaseCurrency().then((_) {
      fetchCurrencyData().then((ratesData) {
        if (baseCurrency.isNotEmpty) {
          // Ensure this fetches the correct default rate on page load
          // fetchExchangeRate();
          CurrencyApiHelper.fetchExchangeRate(fromCurrency, toCurrency);

        }
      });
    });
  }

  Future<Map<String, dynamic>> fetchCurrencyData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return {};

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!doc.exists || !doc.data()!.containsKey('baseCurrency')) return {};

    final currency = doc['baseCurrency'];
    baseCurrency = currency;
    selectedCurrency = currency;
    searchController.text = baseCurrency;

    final url = Uri.parse('https://v6.exchangerate-api.com/v6/2f386b0f1eb2f3e88a4ec4a0/latest/$currency');
    final response = await http.get(url);
    final data = jsonDecode(response.body);

    return data['conversion_rates'];
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
class AlertHelper {
  static Future<bool> hasAlertBeenShown(String alertId) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('shown_alert_$alertId') ?? false;
}

static Future<void> markAlertAsShown(String alertId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('shown_alert_$alertId', true);
}

  static Future<void> checkAndShowAlerts(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;

    if (!notificationsEnabled) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final alertDocs = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('alerts')
          .get();

    for (var doc in alertDocs.docs) {
  final alertId = doc.id;

  if (await hasAlertBeenShown(alertId)) {
    continue; // Skip if already shown
  }

  double targetRate = doc['targetRate'];
  String from = doc['fromCurrency'];
  String to = doc['toCurrency'];

  final currentRate = await CurrencyApiHelper.fetchExchangeRate(from, to);

  if (currentRate != null && currentRate >= targetRate) {
    showAlertPopup(context, from, to, targetRate);
    await markAlertAsShown(alertId);
    break; // Optional: show one at a time
  }
}
 }
  }

  static void showAlertPopup(BuildContext context, String from, String to, double rate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.notifications_active, color: Color(0xFF388E3C)),
            SizedBox(width: 10),
            Text('Rate Alert', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF388E3C))),
          ],
        ),
        content: Text('The rate of $from → $to has reached $rate'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: Color(0xFF388E3C))),
          ),
        ],
      ),
    );
  }
}

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  static const themeColor = Color(0xFF388E3C);

  bool notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    });
  }

  Future<void> _updateNotificationPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
    setState(() {
      notificationsEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
   return Drawer(
  child: ListView(
    padding: EdgeInsets.zero,
    children: [
      DrawerHeader(
        decoration: BoxDecoration(color: themeColor),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Smaller logo
            Image.asset(
              "public/assets/images/bg.png",
              width: 75,
              height: 75,
            ),
            SizedBox(height: 8),
            // App name
            Text(
              'Currensee',
              style: TextStyle(
                color: Colors.white,
                fontSize: 35,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 2.0,
                    color: Colors.black45,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

          _drawerItem(
            icon: Icons.person,
            text: 'Profile',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Profile())),
          ),
          _divider(),
          _drawerItem(
            icon: Icons.history,
            text: 'History',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => History())),
          ),
          _divider(),
          _drawerItem(
            icon: Icons.favorite,
            text: 'Liked Currencies',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LikedCurrrencies())),
          ),
          _divider(),
          _drawerItem(
            icon: Icons.arrow_circle_right_sharp,
            text: 'Check Alerts',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RateAlerts())),
          ),
          _divider(),
          _drawerItem(
            icon: Icons.help,
            text: 'Help Center',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HelpPage())),
          ),
          _divider(),

          // Notifications Toggle
          SwitchListTile(
            title: const Text('Enable Notifications'),
            secondary: const Icon(Icons.notifications_active, color: themeColor),
            value: notificationsEnabled,
            activeColor: themeColor,
            activeTrackColor: Color(0xFFC8E6C9),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.black26,
            onChanged: _updateNotificationPreference,
          ),

          _divider(),
          _drawerItem(
            icon: Icons.logout,
            text: 'Logout',
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 10,
                    title: const Text(
                      'Logout Confirmation',
                      style: TextStyle(color: themeColor),
                    ),
                    content: const Text('Are you sure you want to Logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel', style: TextStyle(color: themeColor)),
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
                          backgroundColor: themeColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: Icon(icon, color: themeColor),
        title: Text(text),
        onTap: onTap,
      ),
    );
  }

  Widget _divider() {
    return const Divider(height: 1);
  }
}
class CurrencyApiHelper {
  static Future<double?> fetchExchangeRate(String fromCurrency, String toCurrency) async {
    final url = Uri.parse('https://v6.exchangerate-api.com/v6/2f386b0f1eb2f3e88a4ec4a0/latest/$fromCurrency');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final rates = data['conversion_rates'];
      if (rates != null && rates[toCurrency] != null) {
        return (rates[toCurrency] as num).toDouble();
      }
    }
    return null;
  }
}



