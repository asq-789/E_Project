import 'dart:convert';
import 'package:currensee/components/bottom_navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currensee/screens/currencyhistory.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:currensee/screens/bars.dart'; // Bars widget
import 'package:shared_preferences/shared_preferences.dart';//shared prefences


class Charts extends StatefulWidget {
  const Charts({super.key});

  @override
  State<Charts> createState() => _ChartsState();
}

class _ChartsState extends State<Charts> {
  TextEditingController searchController = TextEditingController();

  Map<String, double> currencyRates = {};
  List<String> availableCurrencies = [];
  String selectedCurrency = '';
  double selectedRate = 1.0;
  

  // Base currency work
  String baseCurrency = ''; // Base currency set at signup
  Map<String, dynamic>? rates; // history
  List<FlSpot> historicalDataPoints = [];

  bool isCurrencyCardVisible = false; // Flag to toggle visibility of the card
  bool isCrossButtonHovered = false; // Track hover state for the cross button

  @override
  void initState() {
    super.initState();
    fetchCurrencyData().then((ratesData) {
      if (baseCurrency.isNotEmpty) {
        fetchRates(baseCurrency); // Fetch exchange rates for the base currency
      }
    });
    hitAPI();
  }

  // Fetch current base currency data from Firebase
  Future<Map<String, dynamic>> fetchCurrencyData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return {};

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!doc.exists || !doc.data()!.containsKey('baseCurrency')) return {};

    final currency = doc['baseCurrency'];
    baseCurrency = currency;
    selectedCurrency = currency;
    searchController.text = baseCurrency;

    final url = Uri.parse('https://v6.exchangerate-api.com/v6/e0190f187a9c913d9f63e7e4/latest/$currency');
    final response = await http.get(url);
    final data = jsonDecode(response.body);

    return data['conversion_rates'];
  }

  // Fetch exchange rates based on the base currency
  Future<void> fetchRates(String base) async {
    var url = Uri.parse('https://v6.exchangerate-api.com/v6/e0190f187a9c913d9f63e7e4/latest/$base');
    var response = await http.get(url);
    var data = jsonDecode(response.body);

    Map<String, dynamic> rates = data['conversion_rates'];
    Map<String, double> parsedRates = rates.map((key, value) => MapEntry(key, value.toDouble()));

    setState(() {
      currencyRates = parsedRates;
      availableCurrencies = rates.keys.toList();
    });
  }

  // Handle user currency selection from Autocomplete
  void handleCurrencySelection(String value) {
    setState(() {
      selectedCurrency = value;
      selectedRate = currencyRates[value] ?? 1.0;
      isCurrencyCardVisible = true; // Show the card after selection
    });
  }

  // Fetch historical data for the base currency
  Future<void> hitAPI() async {
    print('Sending API request...');

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
            rates = data['quotes'];
            historicalDataPoints = spots;
          });
        } else {
          print('No rates found in response');
        }
      } catch (e) {
        print('Error decoding response: $e');
      }
    } else {
      print("Request failed with status: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Prepare data for the line chart
    var filteredCurrencies = currencyRates.entries.toList();
    filteredCurrencies.sort((a, b) => b.value.compareTo(a.value));
    if (filteredCurrencies.length > 10) {
      filteredCurrencies = filteredCurrencies.sublist(0, 10);
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double chartWidth = screenWidth;
    double chartHeight = screenHeight * 0.35;

    const themeColor = Color(0xFF388E3C);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Charts'),
        actions: [
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
        ],
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
      ),
      body: currencyRates.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Exchange Rates - Top 10 Currencies',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Autocomplete widget for other currencies
                  // Autocomplete widget for other currencies
Autocomplete<String>(
  optionsBuilder: (TextEditingValue textEditingValue) {
    return availableCurrencies
        .where((currency) =>
            currency.toLowerCase().contains(textEditingValue.text.toLowerCase()))
        .toList();
  },
  fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
    return Column(
      children: [
        FocusScope( // Add a FocusScope to manage the focus behavior
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(focusNode); // Ensure focus is handled properly
            },
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Select Currency',
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Show the card when a currency is selected
        if (isCurrencyCardVisible) 
          Container(
            height: 150, // Set height of the card
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: themeColor, // Set background color to green
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.grey)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: MouseRegion(
                    onEnter: (_) {
                      setState(() {
                        isCrossButtonHovered = true; // On hover, change cross button color
                      });
                    },
                    onExit: (_) {
                      setState(() {
                        isCrossButtonHovered = false; // On exit, reset hover state
                      });
                    },
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: isCrossButtonHovered ? Colors.red : Colors.white, // Red on hover, white by default
                      ),
                      onPressed: () {
                        setState(() {
                          isCurrencyCardVisible = false; // Hide the card on close
                        });
                      },
                    ),
                  ),
                ),
                Text(
                  'Currency: $selectedCurrency',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Set text color to white
                  ),
                ),
                const SizedBox(height: 4), // Reduced space between the two texts
                Text(
                  'Exchange Rate: ${selectedRate.toStringAsFixed(4)}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white, // Set text color to white
                  ),
                ),
                const SizedBox(height: 4), // Reduced space between the texts
                Text(
                  'Base Currency: $baseCurrency',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white, // Set text color to white
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  },
  onSelected: handleCurrencySelection,
),

                    const SizedBox(height: 16),

                    // Base Currency Info Container
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: chartWidth,
                      decoration: BoxDecoration(
                        color: themeColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Base Currency: $baseCurrency',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Exchange Rates relative to $baseCurrency',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Line Chart for Top 10 Currencies
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

                    const SizedBox(height: 32),

                    // Historical Data Chart
                    const Text(
                      'Historical Data - 2005-02-01',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    if (historicalDataPoints.isEmpty)
                      const Center(child: CircularProgressIndicator())
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
                                color: Colors.blue,
                                barWidth: 3,
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
    );
  }
}
