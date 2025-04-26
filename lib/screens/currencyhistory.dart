import 'dart:convert';
import 'package:currensee/components/bottom_navbar.dart';
import 'package:currensee/components/my_appbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

String selectedCurrency = "USD";

class Currencyhistory extends StatefulWidget {
  const Currencyhistory({super.key});

  @override
  State<Currencyhistory> createState() => _CurrencyhistoryState();
}

class _CurrencyhistoryState extends State<Currencyhistory> {
  Map<String, dynamic>? rates;
  bool notificationsEnabled = false;
  int numberOfDays = 0;

  Future<void> hitAPI() async {
    final fromDate = DateTime(2024, 4, 1);
    final toDate = DateTime(2024, 4, 10);
    final base = selectedCurrency;

    final url = Uri.parse("https://api.frankfurter.app/${DateFormat('yyyy-MM-dd').format(fromDate)}..${DateFormat('yyyy-MM-dd').format(toDate)}?from=$base");

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
  }

  String formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('MMMM d, yyyy').format(date);
  }

  @override
  void initState() {
    super.initState();
    hitAPI();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        notificationsEnabled: notificationsEnabled,
        title: "Currency history",
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
      body: rates == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  // ✅ Heading Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Showing rates for past $numberOfDays days',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Base: $selectedCurrency',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // ✅ List of rates
                  Expanded(
                    child: ListView(
                      children: rates!.entries.map((entry) {
                        String date = formatDate(entry.key);
                        Map<String, dynamic> dailyRates = entry.value;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ExpansionTile(
                            title: Text(
                              "Date: $date",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            children: [
                              SizedBox(
                                height: 200, // Fixed scrollable height
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: dailyRates.length,
                                  itemBuilder: (context, index) {
                                    String currency = dailyRates.keys.elementAt(index);
                                    double rate = dailyRates[currency].toDouble();

                                    return ListTile(
                                      title: Text(currency),
                                      subtitle: Text('Rate: $rate'),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
bottomNavigationBar: BottomNavBar(currentIndex: 0), // Home
    );
  }
}