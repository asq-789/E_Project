import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Currencyhistory extends StatefulWidget {
  const Currencyhistory({super.key});

  @override
  State<Currencyhistory> createState() => _CurrencyhistoryState();
}

class _CurrencyhistoryState extends State<Currencyhistory> {
  Map<String, dynamic>? rates;

  // API call
  Future<void> hitAPI() async {
    print('Sending API request...');
    
    final response = await http.get(
      Uri.parse("https://api.exchangerate.host/historical?access_key=4ad007e6d6703362a5dfc278358a7f00&date=2005-02-01"),
    );

    if (response.statusCode == 200) {
      print('API Response: ${response.body}'); // Print full response for debugging

      try {
        final data = jsonDecode(response.body);

        if (data['quotes'] != null) {
          print('Data found: ${data['quotes']}'); // Print the rates data for debugging

          setState(() {
            rates = data['quotes'];
          });
        } else {
          print( 'No rates found in response');
        }
      } catch (e) {
        print(' Error decoding response: $e');
      }
    } else {
      print(" Request failed with status: ${response.statusCode}");
    }
  }

  @override
  void initState() {
    super.initState();
    print('initState called. Fetching data...');
    hitAPI(); // Call the API when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Currency History')),
      body: rates == null
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator until data is fetched
          : rates!.isEmpty
              ? const Center(child: Text('No data available.'))
              : ListView.builder(
                  itemCount: rates!.length,
                  itemBuilder: (context, index) {
                    String currency = rates!.keys.elementAt(index);
                    dynamic rate = rates![currency];

                    // Print each currency and its rate for debugging
                    print('Currency: $currency, Rate: $rate');

                    return ListTile(
                      title: Text(currency),
                      subtitle: Text(rate.toString()),
                    );
                  },
                ),
    );
  }
}
