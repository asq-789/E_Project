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
  bool isSaved = false;

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
        DocumentSnapshot snapshot =
            await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
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

  conversionsHistory() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('history').add({
          'amount': amount,
          'from_currency': fromCurrency,
          'to_currency': toCurrency,
          'rate': rate.toStringAsFixed(2),  // Rounded to 2 decimal places
          'total': total.toStringAsFixed(2),  // Rounded to 2 decimal places
          'timestamp': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
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
    amount = double.tryParse(amountController.text) ?? 0.0;
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

 
  // Appbar
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  CustomAppBar(
        notificationsEnabled: notificationsEnabled,
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: currencies.isEmpty
            ? Center(child: CircularProgressIndicator(color: Color(0xFF388E3C)))
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
                        SizedBox(width: 5,),
                        Icon(Icons.arrow_forward, size: 22),
                         SizedBox(width: 5,),
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
                      onPressed: () {
                        if (amountController.text.isEmpty || double.tryParse(amountController.text) == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Please enter a valid amount")),
                          );
                          return;
                        }

                        getRateAndConvert();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF388E3C)),
                      child: Text("Convert", style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                    SizedBox(height: 20),
                    if (rate != 0.0 && !isSaved)
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "1 $fromCurrency = ${rate.toStringAsFixed(2)} $toCurrency",
                                          style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          "$amount $fromCurrency = ${total.toStringAsFixed(2)} $toCurrency",
                                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 11.0, left: 10.0),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: OutlinedButton(
                                        onPressed: () async {
                                          await conversionsHistory();
                                          setState(() {
                                            isSaved = true;
                                          });
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("Conversion saved!")),
                                          );
                                        },
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: Color(0xFF388E3C)),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Text(
                                          "Save",
                                          style: TextStyle(color: Color(0xFF388E3C)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: InkWell(
                                                               onTap: () {
                                  setState(() {
                                    rate = 0.0;
                                    total = 0.0;
                                    isSaved = false;
                                    amountController.clear();
                                  });
                                },
                                child: Icon(Icons.close, color: Colors.grey,size: 16,),
                              ),
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
