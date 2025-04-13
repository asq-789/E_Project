import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class Charts extends StatefulWidget {
  const Charts({super.key});

  @override
  State<Charts> createState() => _ChartsState();
}

class _ChartsState extends State<Charts> {
  Map<String, double> currencyRates = {};
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  String selectedCurrency = 'USD'; // Default currency is USD
  double selectedRate = 1.0; // Default rate for USD is 1.0

  @override
  void initState() {
    super.initState();
    fetchRates();
  }

  Future<void> fetchRates() async {
    var url = Uri.parse('https://v6.exchangerate-api.com/v6/6aa43d570c95f0577517c38d/latest/USD');
    var response = await http.get(url);
    var data = jsonDecode(response.body);

    Map<String, dynamic> rates = data['conversion_rates'];
    Map<String, double> parsedRates = rates.map((key, value) => MapEntry(key, value.toDouble()));

    setState(() {
      currencyRates = parsedRates;
    });
  }

  void updateCurrencyDetail(String currency, double rate) {
    setState(() {
      selectedCurrency = currency;
      selectedRate = rate;
    });
  }

  @override
  Widget build(BuildContext context) {
    var filteredCurrencies = currencyRates.entries
        .where((entry) {
          final search = searchController.text.toLowerCase();
          return entry.key.toLowerCase().contains(search);
        })
        .toList();

    // Sort the currencies by value and get top 10
    filteredCurrencies.sort((a, b) => b.value.compareTo(a.value));
    if (filteredCurrencies.length > 10) {
      filteredCurrencies = filteredCurrencies.sublist(0, 10);
    }

    // Get the screen width
    double screenWidth = MediaQuery.of(context).size.width;

    // Calculate chart width based on screen width (leave some padding)
    double chartWidth = screenWidth - 32.0; // 16px padding on each side

    // Set chart height
    double chartHeight = 300.0;

    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
                controller: searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search Currency...',
                  border: InputBorder.none,
                ),
                onChanged: (_) => setState(() {}),
              )
            : const Text('Currency Chart'),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) searchController.clear();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // TODO: Implement history navigation
            },
          ),
        ],
        backgroundColor: const Color(0xFF388E3C),
      ),
      //currency record show
      body: currencyRates.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: filteredCurrencies.isEmpty
                  ? const Center(child: Text('No currencies found'))
                  : Column(
                      children: [
                        // Information box above the chart
                        Container(
                          padding: const EdgeInsets.all(16),
                          width: chartWidth,
                          color: Colors.blueAccent,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Currency: $selectedCurrency',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Exchange Rate: $selectedRate',
                                style: const TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Stack Widget for chart and currency points
                        Stack(
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: chartWidth, // Set responsive chart width
                                height: chartHeight, // Set chart height
                                child: LineChart(
                                  LineChartData(
                                    gridData: FlGridData(show: true, drawVerticalLine: false),
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
                                        color: Colors.blueAccent,
                                        barWidth: 4,
                                        belowBarData: BarAreaData(show: false),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Detecting hover or tap on chart points
                            for (int i = 0; i < filteredCurrencies.length; i++)
                              Positioned(
                                left: (i * (chartWidth / filteredCurrencies.length)) + 16,
                                top: chartHeight - (filteredCurrencies[i].value * 10), // Adjust height based on value
                                child: GestureDetector(
                                  onTap: () {
                                    updateCurrencyDetail(filteredCurrencies[i].key, filteredCurrencies[i].value);
                                  },
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
            ),
    );
  }
}
