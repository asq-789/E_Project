import 'package:currensee/components/bottom_navbar.dart';
import 'package:currensee/screens/currencyhistory.dart';
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
  TextEditingController searchController = TextEditingController();
  TextEditingController alertRateController = TextEditingController(); // For setting alert
  TextEditingController alertCurrencyController = TextEditingController(); // For currency selection

  Map<String, double> currencyRates = {};
  List<String> availableCurrencies = [];
  String selectedCurrency = '';
  double selectedRate = 1.0;

  double? alertRate; // For the target rate in the alert
  String? alertCurrency; // For the target currency in the alert

  String baseCurrency = '';
  Map<String, dynamic>? rates;
  List<FlSpot> historicalDataPoints = [];

  bool isCurrencyCardVisible = false;
  bool isCrossButtonHovered = false;

  @override
  void initState() {
    super.initState();
    fetchCurrencyData().then((ratesData) {
      if (baseCurrency.isNotEmpty) {
        fetchRates(baseCurrency);
      }
    });
    hitAPI();
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

    final url = Uri.parse('https://v6.exchangerate-api.com/v6/e0190f187a9c913d9f63e7e4/latest/$currency');
    final response = await http.get(url);
    final data = jsonDecode(response.body);

    return data['conversion_rates'];
  }

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

  void handleCurrencySelection(String value) {
    setState(() {
      selectedCurrency = value;
      selectedRate = currencyRates[value] ?? 1.0;
      isCurrencyCardVisible = true;
    });
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
            rates = data['quotes'];
            historicalDataPoints = spots;
          });
        }
      } catch (e) {
        print('Error decoding response: $e');
      }
    }
  }

  // Set alert
  void showSetAlertDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Alert'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Autocomplete widget for selecting currency
              Autocomplete<String>( 
                optionsBuilder: (TextEditingValue textEditingValue) {
                  return availableCurrencies
                      .where((currency) => currency.toLowerCase().contains(textEditingValue.text.toLowerCase()))
                      .toList();
                },
                fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter Currency (e.g., USD, EUR)',
                    ),
                  );
                },
                onSelected: (String value) {
                  alertCurrencyController.text = value;
                  setState(() {
                    alertCurrency = value.toUpperCase();
                  });
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: alertRateController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter target rate',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (alertCurrencyController.text.isNotEmpty && alertRateController.text.isNotEmpty) {
                  setState(() {
                    alertRate = double.tryParse(alertRateController.text);
                    alertCurrency = alertCurrencyController.text.toUpperCase();
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Alert set successfully!')) ,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter both currency and target rate!')) ,
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

  // Check alert
  void checkAlert() {
    if (alertRate != null && alertCurrency != null) {
      if (selectedCurrency.toUpperCase() == alertCurrency!.toUpperCase() && selectedRate >= alertRate!) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Alert! $alertCurrency has reached $alertRate'),
            backgroundColor: Colors.green,
          ),
        );
        alertRate = null; // Reset alert after triggered
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    Row(
                      children: [
                        Expanded(
                          child: Autocomplete<String>(
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              return availableCurrencies
                                  .where((currency) => currency.toLowerCase().contains(textEditingValue.text.toLowerCase()))
                                  .toList();
                            },
                            fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Select Currency',
                                ),
                              );
                            },
                            onSelected: handleCurrencySelection,
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (alertRate != null)
                          Text(
                            'Target Rate: $alertRate',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: themeColor,
                            ),
                          )
                        else
                          ElevatedButton(
                            onPressed: showSetAlertDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeColor,
                            ),
                            child: const Text('Set Alert'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (isCurrencyCardVisible)
                      Container(
                        height: 150,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: themeColor,
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
                                    isCrossButtonHovered = true;
                                  });
                                },
                                onExit: (_) {
                                  setState(() {
                                    isCrossButtonHovered = false;
                                  });
                                },
                                child: IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: isCrossButtonHovered ? Colors.red : Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isCurrencyCardVisible = false;
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
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Exchange Rate: ${selectedRate.toStringAsFixed(4)}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Base Currency: $baseCurrency',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
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
      bottomNavigationBar:  BottomNavBar(currentIndex: 1),
    );
  }
}
