import 'dart:convert';
import 'package:currensee/helppage.dart';
import 'package:currensee/screens/Charts.dart';
import 'package:currensee/screens/contactus.dart';
import 'package:currensee/screens/currency_list.dart';
import 'package:currensee/screens/feedback.dart';
import 'package:currensee/screens/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String fromCurrency = 'USD';
  String toCurrency = 'PKR';
  double rate = 0.0;
  double total = 0.0;
  TextEditingController amountController = TextEditingController();
  List<String> currencies = [];
  int _selectedIndex = 0;
  bool notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    getcurrencies();
  }

  Future<void> getcurrencies() async {
    try {
      var url = Uri.parse('https://v6.exchangerate-api.com/v6/6aa43d570c95f0577517c38d/latest/USD');
      var response = await http.get(url);
      var data = jsonDecode(response.body);
      setState(() {
        currencies = (data['conversion_rates'] as Map<String, dynamic>).keys.toList();
      });
    } catch (e) {
      print("Error fetching currencies: $e");
    }
  }

  Future<void> getRate() async {
    try {
      var url = Uri.parse('https://v6.exchangerate-api.com/v6/6aa43d570c95f0577517c38d/latest/$fromCurrency');
      var response = await http.get(url);
      var data = jsonDecode(response.body);
      setState(() {
        rate = data["conversion_rates"][toCurrency];
      });
    } catch (e) {
      print("Error fetching rate: $e");
    }
  }

  getRateAndConvert() async {
    if (amountController.text.isEmpty) return;
    double amount = double.tryParse(amountController.text) ?? 0.0;
    try {
      var url = Uri.parse('https://v6.exchangerate-api.com/v6/6aa43d570c95f0577517c38d/latest/$fromCurrency');
      var response = await http.get(url);
      var data = jsonDecode(response.body);
      setState(() {
        rate = data['conversion_rates'][toCurrency];
        total = amount * rate;
      });
    } catch (e) {
      print("Error converting rate: $e");
    }
  }

  void swapCurrencies() {
    setState(() {
      String temp = fromCurrency;
      fromCurrency = toCurrency;
      toCurrency = temp;
      total = 0.0;
      rate = 0.0;
    });
  }

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

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: currencies.isEmpty
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      "Welcome to Currensee! 💱",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 30),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        label: Text("Amount"),
                        hintText: "Enter Amount",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: currencies.contains(fromCurrency) ? fromCurrency : null,
                            decoration: InputDecoration(label: Text("From"), border: OutlineInputBorder()),
                            items: currencies.map((currency) {
                              return DropdownMenuItem(value: currency, child: Text(currency));
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                fromCurrency = newValue!;
                              });
                            },
                          ),
                        ),
                        Icon(Icons.swap_horiz, size: 40),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: currencies.contains(toCurrency) ? toCurrency : null,
                            decoration: InputDecoration(label: Text("To"), border: OutlineInputBorder()),
                            items: currencies.map((currency) {
                              return DropdownMenuItem(value: currency, child: Text(currency));
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                toCurrency = newValue!;
                              });
                            },
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: getRateAndConvert,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF388E3C)),
                      child: Text("Convert", style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                    SizedBox(height: 20),
                    if (rate != 0.0) ...[
                      Text("Rate: $rate", style: TextStyle(fontSize: 20)),
                      SizedBox(height: 10),
                      Text('Total: ${total.toStringAsFixed(3)}', style: TextStyle(fontSize: 30)),
                    ],
                  ],
                ),
              ),
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
