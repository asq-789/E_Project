import 'dart:convert';
import 'package:currensee/screens/ArticlesPage.dart';
import 'package:currensee/screens/TrendsPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Dummy Pages for Navigation
// class NewsPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('News')),
//       body: Center(child: const Text('News content goes here')),
//     );
//   }
// }

// class TrendsPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Trends')),
//       body: Center(child: const Text('Trends content goes here')),
//     );
//   }
// }

// class ArticlesPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Articles')),
//       body: Center(child: const Text('Articles content goes here')),
//     );
//   }
// }

class CurrencyMarket extends StatefulWidget {
  const CurrencyMarket({super.key});

  @override
  State<CurrencyMarket> createState() => _CurrencyMarketState();
}

class _CurrencyMarketState extends State<CurrencyMarket> {
  List<Map<String, dynamic>> marketData = [];

  Future<void> fetchMarketData() async {
    final url = Uri.parse(
        "https://api.twelvedata.com/time_series?symbol=ETH/BTC:Huobi,TRP:TSX,INFY:BSE&interval=30min&outputsize=12&apikey=demo&source=docs");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        List<Map<String, dynamic>> extracted = [];

        for (var entry in data.entries) {
          final symbolKey = entry.key;
          final symbolData = entry.value;

          if (symbolData['status'] == 'ok' &&
              symbolData['meta'] != null &&
              symbolData['values'] != null &&
              symbolData['values'].isNotEmpty) {
            final meta = symbolData['meta'];
            final latestValue = symbolData['values'][0]; // most recent data point

            extracted.add({
              'symbol': meta['symbol'],
              'exchange': meta['exchange'],
              'type': meta['type'],
              'datetime': latestValue['datetime'],
              'close': latestValue['close'],
            });
          }
        }

        setState(() {
          marketData = extracted;
        });
      } else {
        print('Failed to load data. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMarketData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Market')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                     MaterialPageRoute(builder: (context) => CurrencyMarket()),
                    );
                  },
                  child: const Text('News'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Trendspage()),
                    );
                  },
                  child: const Text('Trends'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Articlespage()),
                    );
                  },
                  child: const Text('Articles'),
                ),
              ],
            ),
          ),
          const Divider(), // optional for visual separation
          Expanded(
            child: marketData.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: marketData.length,
                    itemBuilder: (context, index) {
                      final item = marketData[index];
                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(item['symbol'] ?? ''),
                          subtitle: Text('${item['exchange']} • ${item['type']}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Latest Close'),
                              Text(
                                item['close'] ?? 'N/A',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text(item['symbol']),
                                content: Text('Close: ${item['close']}\nTime: ${item['datetime']}'),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
