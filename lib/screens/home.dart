import 'dart:convert';
import 'package:currensee/helppage.dart';
import 'package:currensee/screens/Charts.dart';
import 'package:currensee/screens/contactus.dart';
import 'package:currensee/screens/currency_list.dart';
import 'package:currensee/screens/feedback.dart';
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
  bool notificationsEnabled = false; // notification state

  @override
  void initState() {
    super.initState();
    getcurrencies();
  }

  Future<void> getcurrencies() async {
    var url = Uri.parse(
        'https://v6.exchangerate-api.com/v6/6aa43d570c95f0577517c38d/latest/USD');
    var response = await http.get(url);
    var data = jsonDecode(response.body);
    setState(() {
      currencies =
          (data['conversion_rates'] as Map<String, dynamic>).keys.toList();
    });
  }

  Future<void> getRate() async {
    var url = Uri.parse(
        'https://v6.exchangerate-api.com/v6/6aa43d570c95f0577517c38d/latest/$fromCurrency');
    var response = await http.get(url);
    var data = jsonDecode(response.body);
    setState(() {
      rate = data["conversion_rates"][toCurrency];
    });
  }

  getRateAndConvert() async {
    if (amountController.text.isEmpty) return;
    double amount = double.tryParse(amountController.text) ?? 0.0;
    var url = Uri.parse(
        'https://v6.exchangerate-api.com/v6/6aa43d570c95f0577517c38d/latest/$fromCurrency');
    var response = await http.get(url);
    var data = jsonDecode(response.body);
    setState(() {
      rate = data['conversion_rates'][toCurrency];
      total = amount * rate;
    });
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
    
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
      break;
    case 1:
    
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Charts()),
      );
      break;
    case 2:
      
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CurrencyList()),
      );
      break;
    case 3:
      
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ContactScreen()),
      );
      break;
    case 4:
      
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FeedbackScreen()),
      );
      break;
    default:
      break;
  }
}


  // Show the settings menu
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
                  // Profile screen 
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.history),
                title: Text('History'),
                onTap: () {
                  //  History screen
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.notifications),
                title: Text('Notifications'),
                trailing: Switch(
                  value: notificationsEnabled,
                  onChanged:  (bool value) {
                      print("Notifications Enabled: $value");
                    setState(() {
                      notificationsEnabled = value; // Toggle notification state
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    notificationsEnabled = !notificationsEnabled; // Toggle notification on tap
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.help),
                title: Text('Help Center'),
                onTap: () {
                   Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HelpPage()),
      );
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => HelpPage()),
);
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: () async{//logout
                await FirebaseAuth.instance.signOut();//import package
                  Navigator.restorablePopAndPushNamed(context, "/login");
               // };

                },
              ),
            ],
          ),
        );
      },
    );
  }
//app bar
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.menu, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF388E3C),
        title: Text("Currensee", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              setState(() {
                notificationsEnabled = !notificationsEnabled; // notification
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () => _showSettings(context), // Open settings menu
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
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
                      decoration: InputDecoration(
                        label: Text("From"),
                        border: OutlineInputBorder(),
                      ),
                      items: currencies.map((currency) {
                        return DropdownMenuItem(
                            value: currency, child: Text(currency));
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
                      decoration: InputDecoration(
                        label: Text("To"),
                        border: OutlineInputBorder(),
                      ),
                      items: currencies.map((currency) {
                        return DropdownMenuItem(
                            value: currency, child: Text(currency));
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF388E3C),
                ),
                child: Text("Convert",
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
              SizedBox(height: 20),
              if (rate != 0.0) ...[
                Text("Rate: $rate", style: TextStyle(fontSize: 20)),
                SizedBox(height: 10),
                Text('Total: ${total.toStringAsFixed(3)}',
                    style: TextStyle(fontSize: 30)),
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
