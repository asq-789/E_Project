import 'dart:convert';
import 'package:currensee/components/bottom_navbar.dart';
import 'package:currensee/components/my_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double amount = 0.0;
  String fromCurrency = '';
  String toCurrency = 'PKR';
  double rate = 0.0;
  double total = 0.0;

  TextEditingController amountController = TextEditingController();
  List<String> currencies = [];
  List<String> likedCurrencies = [];
  bool notificationsEnabled = false;
Map<String, dynamic>? marketData;
 Map<String, dynamic>? rates;
  final fromDate = DateTime(2024, 4, 1);
    final toDate = DateTime(2024, 4, 10);
  int numberOfDays = 0;
 bool _hasCheckedAlerts = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasCheckedAlerts) {
      _hasCheckedAlerts = true;
      checkAlertsIfEnabled();
    }
  }
  
  @override
  void initState() {
    super.initState();
    getcurrencies();
    fetchUserData();
    fetchMarketData();
  }
  void checkAlertsIfEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notificationsEnabled') ?? false;
    if (enabled) {
      AlertHelper.checkAndShowAlerts(context);
    }
  }


  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (snapshot.exists && snapshot.data() != null) {
          var data = snapshot.data() as Map<String, dynamic>;
          String? base = data['baseCurrency'];
          List<dynamic>? liked = data['likedCurrencies'];

          if (base != null && base.isNotEmpty) {
            setState(() {
              fromCurrency = base;
            });
          }
          if (liked != null) {
            setState(() {
              likedCurrencies = List<String>.from(liked);
            });
          }
        }
      } catch (e) {
        print("Error loading user data: $e");
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
      var url = Uri.parse('https://v6.exchangerate-api.com/v6/797d237e9f8275c429bf32bf/latest/USD');
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
      var url = Uri.parse('https://v6.exchangerate-api.com/v6/797d237e9f8275c429bf32bf/latest/$fromCurrency');
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

  InputDecoration _inputDecoration(
  String label,
  IconData icon, {
  double iconSize = 20,
}) {
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(
      fontWeight: FontWeight.w500,
      color: Color(0xFF388E3C),
    ),
    prefixIcon: Icon(
      icon,
      size: iconSize,
      color: Color(0xFF388E3C),
    ),
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
          title: Text("Conversion Result", style: TextStyle(color: Color(0xFF388E3C),fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("1 $fromCurrency = ${rate.toStringAsFixed(2)} $toCurrency", style: TextStyle(color: Colors.grey[700])),
              SizedBox(height: 10),
              Text("$amount $fromCurrency = ${total.toStringAsFixed(2)} $toCurrency", style: TextStyle(fontSize: 16)),
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
      ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Text(
      "Conversion saved!",
      style: TextStyle(color: Colors.white),
    ),
    backgroundColor: const Color(0xFF388E3C),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.horizontal(
        left: Radius.circular(20),
        right: Radius.circular(20),
      ),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    duration: const Duration(seconds: 2),
  ),
);

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
Future<void> fetchMarketData() async {
  try {
    final response = await http.get(Uri.parse('https://api.coingecko.com/api/v3/global'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        marketData = data['data']; 
      });
    }
  } catch (e) {
    print('Error fetching global market data: $e');
  }
}

@override
Widget buildMarketAnalysis() {
  if (marketData == null) return const SizedBox(); 

  double marketCap = marketData!['total_market_cap']['usd'];
  double marketCapChange = marketData!['market_cap_change_percentage_24h_usd'];
  double btcDominance = marketData!['market_cap_percentage']['btc'];

  return Card(
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "📊 Market Overview",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.attach_money, color: Colors.green, size: 18),
              const SizedBox(width: 5),
              Text("Total Market Value", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Text(
            "The total value of all cryptocurrencies combined is \$${marketCap.toStringAsFixed(0)}",
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                marketCapChange > 0 ? Icons.trending_up : Icons.trending_down,
                color: marketCapChange > 0 ? Colors.green : Colors.red,
                size: 18,
              ),
              const SizedBox(width: 5),
              Text("24h Market Change", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Text(
            "The market cap has changed by ${marketCapChange.toStringAsFixed(2)}% in the last 24 hours.",
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.currency_bitcoin, color: Colors.orange, size: 18),
              const SizedBox(width: 5),
              Text("Bitcoin Dominance", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Text(
            "Bitcoin currently makes up ${btcDominance.toStringAsFixed(2)}% of the entire crypto market.",
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    ),
  );
}
Future<void> fetchCurrencyHistory(DateTime startDate, DateTime endDate, String fromCurrency, String toCurrency) async {
  try {
    final url = Uri.parse(
      "https://api.frankfurter.app/${DateFormat('yyyy-MM-dd').format(startDate)}..${DateFormat('yyyy-MM-dd').format(endDate)}?from=$fromCurrency&to=$toCurrency"
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body); 
      final ratesMap = data["rates"];  

      setState(() {
        rates = ratesMap;  
        numberOfDays = ratesMap.length; 
      });

      print("Fetched all currency rates: $rates");
    } else {
      print("Failed to fetch historical data: ${response.statusCode}");
    }
  } catch (e) {
    print("Error fetching data: $e");  
  }
}

  @override
  Widget build(BuildContext context) {
    List<String> combinedCurrencies = [
      ...likedCurrencies,
      ...currencies.where((currency) => !likedCurrencies.contains(currency)),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        notificationsEnabled: notificationsEnabled,
        title: "Currency Converter",
        onToggleNotifications: () {
          setState(() {
            notificationsEnabled = !notificationsEnabled;
          });
        },
      ),
      drawer: CustomDrawer(),
      body: currencies.isEmpty
          ? Center(child: CircularProgressIndicator(color: Color(0xFF388E3C)))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 10),
                    Center(child: Text("Welcome to Currensee! 💱", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Color(0xFF388E3C), shadows: [Shadow(offset: Offset(2, 2), blurRadius: 3, color: Color.fromARGB(66, 114, 114, 113))]), textAlign: TextAlign.center)),
                    Center(child: Text("Ready to convert some currencies?", style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey[600]))),
                    SizedBox(height: 30),
                    TextField(controller: amountController, keyboardType: TextInputType.number, decoration: _inputDecoration("Amount", Icons.attach_money)),
                    SizedBox(height: 30),
                    Row(children: [
                      Expanded(child: DropdownButtonFormField<String>(
                        value: currencies.contains(fromCurrency) ? fromCurrency : null,
                        decoration: _inputDecoration("From", Icons.arrow_downward , iconSize: 16,),
                        items: combinedCurrencies.map((currency) => DropdownMenuItem(value: currency, child: Text(currency,style: TextStyle(fontSize: 15)))).toList(),
                       selectedItemBuilder: (BuildContext context) {
    return combinedCurrencies.map((currency) {
      return Text(
        currency,
        style: TextStyle(fontSize: 15), 
        overflow: TextOverflow.ellipsis,
      );
    }).toList();
  }, onChanged: (newValue) => setState(() => fromCurrency = newValue!),
                      )),
                     
                    SizedBox(
      width: 22,
      child: Center(
        child: Icon(Icons.swap_vert, color: Colors.grey, size: 20),
      ),
    ),
                  
                      Expanded(
                        child: DropdownButtonFormField<String>(
                        value: currencies.contains(toCurrency) ? toCurrency : null,
                        decoration: _inputDecoration("To", Icons.arrow_upward, iconSize: 16,),
                        items: combinedCurrencies.map((currency) => DropdownMenuItem(value: currency, child: Text(currency, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15,)))).toList(),
                        onChanged: (newValue) => setState(() => toCurrency = newValue!),
                      )),
                    ]),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        if (amountController.text.isEmpty || double.tryParse(amountController.text) == null) {
                         ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Text(
      "Please enter a valid amount",
      style: TextStyle(color: Colors.white),
    ),
    backgroundColor: const Color(0xFF388E3C),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.horizontal(
        left: Radius.circular(20),
        right: Radius.circular(20),
      ),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    duration: const Duration(seconds: 2),
  ),
);

                         
                          return;
                        }
                        getRateAndConvert();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF388E3C),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(90)),
                        elevation: 4,
                        shadowColor: Color(0x55388E3C),
                      ),
                      child: Text("Convert", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    SizedBox(height: 30),
                    Container(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(136, 161, 226, 166),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Color.fromARGB(255, 116, 114, 114).withOpacity(0.1), spreadRadius: 2, blurRadius: 8, offset: Offset(0, 3))],
                      ),
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(child: Text("Top Currencies", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Color(0xFF388E3C), shadows: [Shadow(offset: Offset(2, 2), blurRadius: 3, color: Color.fromARGB(66, 114, 114, 113))]))),
                          SizedBox(height: 10),
                          FutureBuilder(
                            future: http.get(Uri.parse('https://v6.exchangerate-api.com/v6/797d237e9f8275c429bf32bf/latest/$fromCurrency')),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator(color: Color(0xFF388E3C)));
                              }else if (snapshot.hasError || !snapshot.hasData) {
                                return Text("Failed to load top currencies", style: TextStyle(color: Color.fromARGB(255, 117, 117, 116)));}
                                 else {
                                var data = jsonDecode(snapshot.data!.body);
                                Map<String, dynamic> rates = data['conversion_rates'];
                                List<String> topList = ['USD', 'EUR', 'GBP', 'PKR', 'INR'];

                               return Column(
  children: [
    ...topList.map((code) => Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            title: Text(
              "1 $fromCurrency = ${rates[code].toStringAsFixed(2)} $code",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: IconButton(
              icon: Icon(
                likedCurrencies.contains(code) ? Icons.star : Icons.star_border,
                color: likedCurrencies.contains(code) ? Color(0xFF388E3C): Colors.grey,
              ),
         onPressed: () async {
  setState(() {
    if (likedCurrencies.contains(code)) {
      likedCurrencies.remove(code);  
    } else {
      likedCurrencies.add(code); 
    }
  });


  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'likedCurrencies': likedCurrencies,
      }, SetOptions(merge: true));  
    } catch (e) {
      print("Error saving liked currencies: $e");
    }
  }
},
  ),
          ),
        )),
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
                    SizedBox(height: 20),

                    Container(
  decoration: BoxDecoration(
                        color: Color.fromARGB(136, 161, 226, 166),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Color(0xFF388E3C).withOpacity(0.2)),
  ),
  padding: EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Center(child: Text("Market Overview", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Color(0xFF388E3C)))),
      SizedBox(height: 12),
      buildMarketAnalysis(),
            SizedBox(height: 15),

        Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton.icon(
                                        onPressed: () {
                                          Navigator.pushNamed(context, '/Trend');
                                        },
                                        icon: Icon(Icons.arrow_forward, color: Color(0xFF388E3C)),
                                        label: Text("View Digital Currencies", style: TextStyle(color: Color(0xFF388E3C), fontWeight: FontWeight.w600)),
                                      ),
                                    ), 
    ],
  ),
),

                    SizedBox(height: 30),
                    
   NewsletterSection(),
                  ],
                ),
              

              ),
           
            ),
      bottomNavigationBar: BottomNavBar(currentIndex: 0),
    );
  }
}

class NewsletterSection extends StatefulWidget {
  @override
  _NewsletterSectionState createState() => _NewsletterSectionState();
}

class _NewsletterSectionState extends State<NewsletterSection> {
  final TextEditingController emailController = TextEditingController();
  String? errorText;

  final Color themeColor = Color(0xFF388E3C);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
      
        Text(
          'Subscribe To Our Newsletter',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: themeColor,
            shadows: [
              Shadow(
                offset: Offset(2, 2),
                blurRadius: 3,
                color: Color.fromARGB(66, 114, 114, 113),
              ),
            ],
          ),
        ),
        SizedBox(height: 4),
    
        Text(
          'Stay updated with the latest news and offers',
          style: TextStyle(
            fontSize: 16,
            fontStyle: FontStyle.italic,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 12),
    
        Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'E-Mail',
                          labelStyle: TextStyle(color: themeColor),
                          prefixIcon: Icon(Icons.email, color: themeColor,size: 20,),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: themeColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: themeColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: themeColor, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red, width: 2),
                          ),
                          errorText: errorText,
                        ),
                      ),
                    ),
                    SizedBox(width: 2,),
                    SizedBox(
  height: 38,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: themeColor,
      padding: EdgeInsets.symmetric(horizontal: 10),
    ),
     onPressed: () {
                        String email = emailController.text.trim();
                        String? error = _validateEmail(email);
                        if (error == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content:  Text(
    'Subscribed with $email',
      style: TextStyle(color: Colors.white),
    ),
    backgroundColor: const Color(0xFF388E3C),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.horizontal(
        left: Radius.circular(20),
        right: Radius.circular(20),
      ),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    duration: const Duration(seconds: 2),
  ),
);
                          setState(() {
                            errorText = null;
                          });
                          emailController.clear();
                        } else {
                          setState(() {
                            errorText = error;
                          });
                        }
                      },
                    
    child: Text('Subscribe', style: TextStyle(color: Colors.white,fontSize: 12)),
  ),
),

                 
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return 'Please enter an email';
    }
    RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegExp.hasMatch(email)) {
      return 'Please enter a valid email';
    }
    return null;
  }
}