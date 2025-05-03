import 'dart:async';

import 'package:currensee/components/bottom_navbar.dart';
import 'package:currensee/components/my_appbar.dart';
import 'package:currensee/screens/currencyhistory.dart';
import 'package:currensee/screens/marketnews.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Charts extends StatefulWidget {
  const Charts({Key? key}) : super(key: key);

  @override
  _ChartsState createState() => _ChartsState();
}

class _ChartsState extends State<Charts> {
  String fromCurrency = 'USD';
  String toCurrency = 'PKR';
  double exchangeRate = 0.0;
  List<MapEntry<String, double>> filteredCurrencies = [];
  List<FlSpot> historicalDataPoints = [];
  Color themeColor = Colors.green;
  String baseCurrency = '';
  String selectedCurrency = '';
  TextEditingController searchController = TextEditingController();
bool hasShownAlert = false;
  bool notificationsEnabled = false;

@override
void initState() {
  super.initState();
  fetchCurrencies();
  
  // Fetch initial currency data (for default rate)
  fetchCurrencyData().then((ratesData) {
    if (baseCurrency.isNotEmpty) {
      // Ensure this fetches the correct default rate on page load
      fetchExchangeRate();
    }
  });

  hitAPI();
  Timer.periodic(Duration(minutes: 1), (timer) {
    checkRateAlerts();
  });
}

Future<void> fetchExchangeRate() async {
  final url = Uri.parse('https://v6.exchangerate-api.com/v6/2f386b0f1eb2f3e88a4ec4a0/latest/$fromCurrency');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    setState(() {
      // Ensure the rate gets updated with the correct value
      exchangeRate = data['conversion_rates'][toCurrency] ?? 0.0;
      filteredCurrencies = (data['conversion_rates'] as Map<String, dynamic>)
          .entries
          .where((e) => ['USD', 'EUR', 'PKR', 'INR', 'GBP'].contains(e.key))
          .map((e) => MapEntry(e.key, (e.value as num).toDouble()))
          .toList();
    });
  } else {
    print('Failed to load exchange rate');
  }
}

void checkRateAlerts() {
  if (!notificationsEnabled) return; // Skip if toggle is off

  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('alerts')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        double targetRate = doc['targetRate'];
        String from = doc['fromCurrency'];  
        String to = doc['toCurrency'];    

        if (exchangeRate >= targetRate) {
          showAlertNotification(from, to, targetRate);
        }
      });
    });
  }
}


void showAlertNotification(String fromCurrency, String toCurrency, double targetRate) {
  if (hasShownAlert) return;

  hasShownAlert = true;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
        backgroundColor: Colors.white,
        title: Row(
          children: const [
            Icon(Icons.notifications_active, color: Color(0xFF388E3C)),
            SizedBox(width: 10),
            Text(
              'Rate Alert',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF388E3C),
              ),
            ),
          ],
        ),
        content: Text(
          'The rate of $fromCurrency → $toCurrency has reached $targetRate',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'OK',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF388E3C),
              ),
            ),
          ),
        ],
      );
    },
  );
}


Future<void> fetchRates(String base) async {
  var url = Uri.parse('https://v6.exchangerate-api.com/v6/2f386b0f1eb2f3e88a4ec4a0/latest/$base');
  var response = await http.get(url);
  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    Map<String, dynamic> rates = data['conversion_rates'];
    if (rates != null) {
      Map<String, double> parsedRates = rates.map((key, value) => MapEntry(key, value.toDouble()));
      setState(() {
        // Store the parsedRates and update available currencies here
        exchangeRate = parsedRates[toCurrency] ?? 0.0;
        filteredCurrencies = (data['conversion_rates'] as Map<String, dynamic>)
            .entries
            .where((e) => ['USD', 'EUR', 'PKR', 'INR', 'GBP'].contains(e.key))
            .map((e) => MapEntry(e.key, (e.value as num).toDouble()))
            .toList();
      });
    } else {
      print("Error: No conversion rates available.");
    }
  } else {
    print('Failed to load exchange rate');
  }
}

Future<void> hitAPI() async {
  final response = await http.get(
    Uri.parse("https://api.exchangerate.host/historical?access_key=4ad007e6d6703362a5dfc278358a7f00&date=2005-02-01"),
  );

  if (response.statusCode == 200) {
    try {
      final data = jsonDecode(response.body);

      if (data['quotes'] != null) {
        List<FlSpot> spots = [];
        int index = 0;
        data['quotes'].forEach((key, value) {
          spots.add(FlSpot(index.toDouble(), value.toDouble()));
          index++;
        });

        setState(() {
          historicalDataPoints = spots;
        });
      } else {
        print("Error: No historical data found.");
      }
    } catch (e) {
      print('Error decoding response: $e');
    }
  } else {
    print('Failed to fetch historical data');
  }
}
List<String> currencies = [];

Future<void> fetchCurrencies() async {
  var url = Uri.parse('https://api.exchangerate-api.com/v4/latest/USD');
  var response = await http.get(url);

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    setState(() {
      currencies = data['rates'].keys.toList();
    });
  } else {
    print('Failed to load currencies');
  }
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


  Future<void> showSetAlertDialog() async {
    final targetRateController = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Set Target Rate',style: TextStyle(color: Color(0xFF388E3C)),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Set your target rate for $fromCurrency to $toCurrency'),
              TextField(
                controller: targetRateController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Target Rate',
                labelStyle: TextStyle(color: Color(0xFF388E3C)),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel',style: TextStyle(color: Color(0xFF388E3C)),),
            ),
           TextButton(
  style: TextButton.styleFrom(
    backgroundColor: Color(0xFF388E3C), 
    foregroundColor: Colors.white,      
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12), 
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), 
    ),
   
  ),
  onPressed: () async {
    final targetRate = double.tryParse(targetRateController.text);
    if (targetRate != null) {
      await saveAlertToFirebase(targetRate);
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid target rate')),
      );
    }
  },
  child: const Text('Set'),
),

          ],
        );
      },
    );
  }

  Future<void> saveAlertToFirebase(double targetRate) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final alertsCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('alerts');

      try {
        await alertsCollection.add({
          'fromCurrency': fromCurrency,
          'toCurrency': toCurrency,
          'targetRate': targetRate,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alert successfully set!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to set alert')),
        );
      }
    }
  }
  
void showNotification(BuildContext context) {
  FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .collection('alerts')
      .get()
      .then((querySnapshot) {
    List<String> alertsList = [];
    querySnapshot.docs.forEach((doc) {
      String alertMessage =
          '${doc['fromCurrency']} → ${doc['toCurrency']} reached ${doc['targetRate']}';
      alertsList.add(alertMessage);
    });

    if (alertsList.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final screenWidth = MediaQuery.of(context).size.width;

          return LayoutBuilder(builder: (context, constraints) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.white,
              titlePadding: const EdgeInsets.all(16),
              title: Row(
                children: [
                  const Icon(Icons.notifications_active, color: Colors.green),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Rate Alerts',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 28, 130, 35),
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth < 350 ? 18 : 22,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: screenWidth < 400 ? screenWidth * 0.85 : 300,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text(
                        "Your set exchange rate targets have been met!",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      ...alertsList.map(
                        (alert) => Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: ListTile(
                            leading: const Icon(Icons.check_circle, color: Colors.green),
                            title: Text(
                              alert,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Dismiss',
                    style: TextStyle(
                      color: Color(0xFF1B5E20),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          });
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('You have no active rate alerts!'),
          backgroundColor: const Color(0xFF388E3C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    }
  });
}


  @override
  Widget build(BuildContext context) {
    double chartWidth = MediaQuery.of(context).size.width;
    double chartHeight = 200;

    return Scaffold(
      backgroundColor: Colors.white,
    appBar: AppBar(
  title: const Text('Currency Tracker'),
  actions: [
    IconButton(
      icon: const Icon(Icons.trending_up, color: Colors.white),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const MarketNewsPage()));
      },
    ),
    IconButton(
      icon: const Icon(Icons.history),
      tooltip: 'Currency History',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Currencyhistory()),
        );
      },
    ),
IconButton(
  icon: const Icon(Icons.notifications),
  tooltip: 'Show Target Rates',
  onPressed: () {
    showNotification(context); // Pass the context here
  },
),



  ],
  backgroundColor: const Color(0xFF388E3C),
  foregroundColor: Colors.white,
),
drawer: CustomDrawer(
      // notificationsEnabled: notificationsEnabled,
      // onNotificationsChanged: (bool value) {
      //   setState(() {
      //     notificationsEnabled = value;
      //   });
      // },
    ),
      body: SingleChildScrollView(
        child: Padding(
  padding: const EdgeInsets.all(25),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Main Heading 
      SizedBox(height: 10,),
      Center(
       
        child: Text(
          "Currency Exchange ", 
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: 26,  
            fontWeight: FontWeight.bold,
            color: Color(0xFF388E3C),  
            shadows: [
              Shadow(
                offset: Offset(2, 2),
                blurRadius: 4,
                color: const Color.fromARGB(66, 114, 114, 113),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
      SizedBox(height: 4),  

      
      Center(
        child: Text(
          "Get real-time exchange rates and monitor historical data",  // Subtitle or description
          style: TextStyle(
            fontSize: 15,
            fontStyle: FontStyle.italic,
            color: Colors.black54,  // A softer color for the subtitle
          ),
          textAlign: TextAlign.center,
        ),
      ),
SizedBox(height: 20,),
      // Rest of your code 
      //dropdown
    Row(
  children: [
    Expanded(child: buildCurrencyDropdown(true)),
    SizedBox(width: 10),
    Icon(Icons.compare_arrows,color:  Color(0xFF388E3C), ),
    SizedBox(width: 10),
    Expanded(child: buildCurrencyDropdown(false)),
  ],
),

              const SizedBox(height: 20),
              Text(
                '1 $fromCurrency = ${exchangeRate.toStringAsFixed(2)} $toCurrency',
                style: const TextStyle(color: Color(0xFF388E3C),fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: chartWidth,
                height: chartHeight,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: themeColor.withOpacity(0.2),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, _) => Text(
                            value.toStringAsFixed(0),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, _) {
                            if (value.toInt() < filteredCurrencies.length) {
                              return RotatedBox(
                                quarterTurns: 1,
                                child: Text(
                                  filteredCurrencies[value.toInt()].key,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                          filteredCurrencies.length,
                          (i) {
                            final entry = filteredCurrencies[i];
                            return FlSpot(i.toDouble(), entry.value);
                          },
                        ),
                        isCurved: true,
                        color: themeColor,
                        barWidth: 4,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: showSetAlertDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF388E3C),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(90),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Create Alert",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
           
              const SizedBox(height: 35),
              Center(
                child: Text(
                  "Historical Data",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF388E3C), // Match your theme color
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 3,
                        color: const Color.fromARGB(66, 114, 114, 113),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
SizedBox(height: 4,),
Center(
  child: Text(
    "Data for 2005-02-01. See how the rates evolved.",
    style: TextStyle(
      fontSize: 15,
      fontStyle: FontStyle.italic,
      color: Colors.black54, 
    ),
    textAlign: TextAlign.center,
  ),
),

           
              const SizedBox(height: 30),
              if (historicalDataPoints.isEmpty)
                const Center(child: CircularProgressIndicator(color: Color(0xFF388E3C)))
              else
                SizedBox(
                  width: chartWidth,
                  height: chartHeight,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(show: true),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: historicalDataPoints,
                          isCurved: true,
                          color: themeColor,
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 1),
    );
  }

Widget buildCurrencyDropdown(bool isFromCurrency) {
  return DropdownButton<String>(
    value: isFromCurrency ? fromCurrency : toCurrency,
    isExpanded: true,
    items: currencies.map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList(),
    onChanged: (newValue) {
      setState(() {
        if (isFromCurrency) {
          fromCurrency = newValue!;
        } else {
          toCurrency = newValue!;
        }
        fetchExchangeRate();
        hitAPI(); 
      });
    },
  );
}
 }
