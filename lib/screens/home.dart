import 'dart:convert';
import 'package:currensee/components/bottom_navbar.dart';
import 'package:currensee/components/my_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double amount = 0.0;
  String fromCurrency = 'USD';
  String toCurrency = 'PKR';
  double rate = 0.0;
  double total = 0.0;

  TextEditingController amountController = TextEditingController();
  List<String> currencies = [];
  bool notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    getcurrencies();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (snapshot.exists && snapshot.data() != null) {
          var data = snapshot.data() as Map<String, dynamic>;
          String? base = data['baseCurrency'];
          if (base != null && base.isNotEmpty) {
            setState(() {
              fromCurrency = base;
            });
          }
        }
      } catch (e) {
        print("Error loading base currency: $e");
      }
    }
  }

  Future<void> conversionsHistory() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('history').add({
          'amount': amount,
          'from_currency': fromCurrency,
          'to_currency': toCurrency,
          'rate': rate.toStringAsFixed(2),
          'total': total.toStringAsFixed(2),
          'timestamp': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> getcurrencies() async {
    try {
      var url = Uri.parse('https://v6.exchangerate-api.com/v6/e0190f187a9c913d9f63e7e4/latest/USD');
      var response = await http.get(url);
      var data = jsonDecode(response.body);
      setState(() {
        currencies = (data['conversion_rates'] as Map<String, dynamic>).keys.toList();
      });
    } catch (e) {
      print("Error fetching currencies: $e");
    }
  }

  getRateAndConvert() async {
    if (amountController.text.isEmpty) return;
    amount = double.tryParse(amountController.text) ?? 0.0;
    try {
      var url = Uri.parse('https://v6.exchangerate-api.com/v6/e0190f187a9c913d9f63e7e4/latest/$fromCurrency');
      var response = await http.get(url);
      var data = jsonDecode(response.body);
      setState(() {
        rate = data['conversion_rates'][toCurrency];
        total = amount * rate;
      });
      _showConversionPopup();
    } catch (e) {
      print("Error converting rate: $e");
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(
      fontWeight: FontWeight.w600,
      color: Color(0xFF388E3C), // Applied theme color here
    ),
    prefixIcon: Icon(icon, color: Color(0xFF388E3C)),
    filled: true,
    fillColor: Colors.grey[100],
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Color(0xFF388E3C), width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[400]!),
    ),
  );
}

 void _showConversionPopup() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Conversion Result", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("1 $fromCurrency = ${rate.toStringAsFixed(2)} $toCurrency",
                style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 10),
            Text("$amount $fromCurrency = ${total.toStringAsFixed(2)} $toCurrency",
                style: TextStyle(fontSize: 16)),
          ],
        ),
        actions: [
          TextButton(
            child: Text("Cancel", style: TextStyle(color: Color(0xFF388E3C))),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              await conversionsHistory();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Conversion saved!")));
            },
           
            label: Text("Save"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF388E3C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        notificationsEnabled: notificationsEnabled,
        title: "Currency Converter",
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
      body: currencies.isEmpty
            ? Center(child: CircularProgressIndicator(color: Color(0xFF388E3C)))
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 20),
                      Center(child: Text("Welcome to Currensee! 💱", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
                      Center(child: Text("Ready to convert some currencies?", style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey[600]))),
                      SizedBox(height: 30),
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration("Amount", Icons.attach_money),
                      ),
                      SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: currencies.contains(fromCurrency) ? fromCurrency : null,
                              decoration: _inputDecoration("From", Icons.arrow_downward),
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
                          const SizedBox(width: 10),
                          Icon(Icons.swap_horiz, color: Colors.grey),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: currencies.contains(toCurrency) ? toCurrency : null,
                              decoration: _inputDecoration("To", Icons.arrow_upward),
                              items: currencies.map((currency) {
                                return DropdownMenuItem(
  value: currency,
  child: Text(
    currency,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(fontWeight: FontWeight.w500),
  ),
);

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
  onPressed: () {
    if (amountController.text.isEmpty || double.tryParse(amountController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter a valid amount")));
      return;
    }
    getRateAndConvert();
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF388E3C),
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 4,
    shadowColor: const Color(0x55388E3C), // soft green glow
  ),
  child: const Text(
    "Convert",
    style: TextStyle(
      fontSize: 16,
      color: Colors.white,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
  ),
),
 SizedBox(height: 30),
                 
Container(
  decoration: BoxDecoration(
    color: Color.fromARGB(136, 161, 226, 166), // light theme background
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: const Color.fromARGB(255, 116, 114, 114).withOpacity(0.1),
        spreadRadius: 2,
        blurRadius: 8,
        offset: Offset(0, 3),
      ),
    ],
  ),
  padding: EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Center(
        child: Text(
          "Top Currencies",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF388E3C),
          ),
        ),
      ),
      SizedBox(height: 10),
      FutureBuilder(
        future: http.get(Uri.parse('https://v6.exchangerate-api.com/v6/e0190f187a9c913d9f63e7e4/latest/$fromCurrency')),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Color(0xFF388E3C)));
          } else if (snapshot.hasError || !snapshot.hasData) {
            return Text("Failed to load top currencies", style: TextStyle(color: Colors.red));
          } else {
            var data = jsonDecode(snapshot.data!.body);
            Map<String, dynamic> rates = data['conversion_rates'];
            List<String> topList = ['USD', 'EUR', 'GBP', 'PKR', 'INR'];

            return Column(
              children: [
                ...topList.map((code) {
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4, // slight elevation for card shadow
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text(
                        "1 $fromCurrency = ${rates[code].toStringAsFixed(2)} $code",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: Icon(Icons.star_border, color: Colors.grey),
                    ),
                  );
                }).toList(),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/currencies');
                    },
                    icon: Icon(Icons.arrow_forward, color: Color(0xFF388E3C)),
                    label: Text(
                      "View More",
                      style: TextStyle(color: Color(0xFF388E3C), fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    ],
  ),
),
 ],
                  ),
                ),
              ),
    
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
