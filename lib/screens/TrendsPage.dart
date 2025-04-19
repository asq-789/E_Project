import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class Trendspage extends StatefulWidget {
  const Trendspage({super.key});

  @override
  State<Trendspage> createState() => TrendspageState();
}

class TrendspageState extends State<Trendspage> {
  List<dynamic> detailedCoins = [];
  bool isLoading = true;
  Map<String, dynamic>? marketData;
  int selectedIndex = 0; // 0 for Coins, 1 for Market Analysis

  @override
  void initState() {
    super.initState();
    fetchTrendingDetailedCoins();
    fetchMarketData();
  }

  Future<void> fetchTrendingDetailedCoins() async {
    try {
      var urlTrending = Uri.parse('https://api.coingecko.com/api/v3/search/trending');
      var responseTrending = await http.get(urlTrending);

      if (responseTrending.statusCode == 200) {
        var data = jsonDecode(responseTrending.body);
        var coins = data['coins'] as List<dynamic>;

        List<String> coinIds = coins.map((coin) => coin['item']['id'].toString()).toList();
        String idsParam = coinIds.join(',');

        var urlDetails = Uri.parse(
          'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=$idsParam&sparkline=true&price_change_percentage=7d',
        );
        var responseDetails = await http.get(urlDetails);

        if (responseDetails.statusCode == 200) {
          setState(() {
            detailedCoins = jsonDecode(responseDetails.body);
            isLoading = false;
          });
        } else {
          throw Exception('Failed to load detailed data');
        }
      } else {
        throw Exception('Failed to load trending list');
      }
    } catch (e) {
      print('Error fetching coins: $e');
      setState(() {
        isLoading = false;
      });
    }
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

  Widget buildMarketAnalysis() {
    if (marketData == null) return const SizedBox();

    double marketCap = marketData!['total_market_cap']['usd'];
    double marketCapChange = marketData!['market_cap_change_percentage_24h_usd'];
    double btcDominance = marketData!['market_cap_percentage']['btc'];

    return Card(
      margin: const EdgeInsets.all(15),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "📊 Market Overview",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Total Market Cap
            Row(
              children: [
                Icon(Icons.attach_money, color: Colors.green, size: 18),
                const SizedBox(width: 5),
                Text(
                  "Total Market Value",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              "The total value of all cryptocurrencies combined is \$${marketCap.toStringAsFixed(0)}",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),

            // 24h Market Cap Change
            Row(
              children: [
                Icon(
                  marketCapChange > 0 ? Icons.trending_up : Icons.trending_down,
                  color: marketCapChange > 0 ? Colors.green : Colors.red,
                  size: 18,
                ),
                const SizedBox(width: 5),
                Text(
                  "24h Market Change",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              "The market cap has changed by ${marketCapChange.toStringAsFixed(2)}% in the last 24 hours.",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),

            // BTC Dominance
            Row(
              children: [
                Icon(Icons.currency_bitcoin, color: Colors.orange, size: 18),
                const SizedBox(width: 5),
                Text(
                  "Bitcoin Dominance",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
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

  Widget buildCoinTile(dynamic coin) {
    List<dynamic> prices = coin['sparkline_in_7d']['price'];
    double startPrice = prices.first;
    double endPrice = prices.last;
    bool isUp = endPrice >= startPrice;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coin Image
            Image.network(coin['image'], width: 40, height: 40),

            const SizedBox(width: 10),

            // Coin Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${coin['name']} (${coin['symbol'].toUpperCase()})",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("Price: \$${coin['current_price']}"),
                  Text("24h Change: ${coin['price_change_percentage_24h'].toStringAsFixed(2)}%"),
                  Text("7d Change: ${coin['price_change_percentage_7d_in_currency']?.toStringAsFixed(2)}%"),
                  Text("Market Cap: \$${coin['market_cap']}"),
                  Text("Rank: #${coin['market_cap_rank']}"),
                ],
              ),
            ),

            // Chart with label
            Column(
              children: [
                const Text(
                  "7D Trend",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 5),
                buildSparklineChart(prices, isUp),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSparklineChart(List<dynamic> sparklineData, bool isUp) {
    List<FlSpot> spots = sparklineData
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.toDouble()))
        .toList();

    return Container(
      height: 60,
      width: 100,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: isUp ? Colors.green : Colors.red,
              belowBarData: BarAreaData(show: false),
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text("Trending Coins"),
            const SizedBox(width: 10),
            ToggleButtons(
              isSelected: [selectedIndex == 0, selectedIndex == 1],
              onPressed: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              selectedColor: Colors.white,  // Highlighted button text color
              selectedBorderColor: Colors.green,  // Border color when selected
              fillColor: Colors.green,  // Fill color for selected button
              color: Colors.black,  // Default text color
              borderRadius: BorderRadius.circular(8),
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Coins'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Market Analysis'),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.blue, // AppBar background color
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : detailedCoins.isEmpty
              ? const Center(child: Text("No coin data available"))
              : Column(
                  children: [
                    if (selectedIndex == 1) buildMarketAnalysis(), // Show Market Analysis if selected
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: detailedCoins.length,
                        itemBuilder: (context, index) {
                          return buildCoinTile(detailedCoins[index]);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
