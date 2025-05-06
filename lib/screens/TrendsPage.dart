import 'dart:convert';
import 'package:currensee/components/bottom_navbar.dart';
import 'package:currensee/components/my_appbar.dart';
import 'package:currensee/screens/marketnews.dart';
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
  int selectedIndex = 0;
  bool notificationsEnabled = false;

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
        if (coinIds.isEmpty) {
          setState(() {
            isLoading = false;
          });
          return;
        }

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

    double marketCap = marketData!['total_market_cap']['usd'] ?? 0;
    double marketCapChange = marketData!['market_cap_change_percentage_24h_usd'] ?? 0;
    double btcDominance = marketData!['market_cap_percentage']['btc'] ?? 0;

   return Card(
  margin: const EdgeInsets.all(15),
  elevation: 2,
  child: Padding(
    padding: const EdgeInsets.all(12.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        const Text(
          "📊 Market Overview",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        buildInfoRow(Icons.attach_money, "Total Market Value"),
                const SizedBox(height: 6),

        Text(
          "The total value of all cryptocurrencies combined is \$${marketCap.toStringAsFixed(0)}",
          style: const TextStyle(color: Colors.grey),
        ),
          const SizedBox(height: 10),
        buildInfoRow(
          marketCapChange > 0 ? Icons.trending_up : Icons.trending_down,
          "24h Market Change",
          iconColor: marketCapChange > 0 ? Colors.green : Colors.red,
        ),
                const SizedBox(height: 6),

        Text(
          "The market cap has changed by ${marketCapChange.toStringAsFixed(2)}% in the last 24 hours.",
          style: const TextStyle(color: Colors.grey),
        ),
                  const SizedBox(height: 10),

        buildInfoRow(Icons.currency_bitcoin, "Bitcoin Dominance"),
        const SizedBox(height: 6),
        Text(
          "Bitcoin currently makes up ${btcDominance.toStringAsFixed(2)}% of the entire crypto market.",
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    ),
  ),
);
}

 Widget buildInfoRow(IconData icon, String label, {Color iconColor = Colors.black}) {
  return Row(
    children: [
      Icon(icon, color: iconColor),
      const SizedBox(width: 8),
      Text(label,style: const TextStyle(fontWeight: FontWeight.bold), ),
    ],
  );
}
Widget buildCoinTile(dynamic coin) {
  List<dynamic> prices = (coin['sparkline_in_7d']?['price'] ?? []) as List<dynamic>;
  double startPrice = prices.isNotEmpty ? prices.first : 0;
  double endPrice = prices.isNotEmpty ? prices.last : 0;
  bool isUp = endPrice >= startPrice;

  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              coin['image'],
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error, size: 40);
              },
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${coin['name']} (${coin['symbol'].toUpperCase()})",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text("Price: \$${coin['current_price'] ?? 'N/A'}"),
                Text("24h Change: ${coin['price_change_percentage_24h']?.toStringAsFixed(2) ?? 'N/A'}%"),
                Text("7d Change: ${coin['price_change_percentage_7d_in_currency']?.toStringAsFixed(2) ?? 'N/A'}%"),
                Text("Market Cap: \$${coin['market_cap'] ?? 'N/A'}"),
                Text("Rank: #${coin['market_cap_rank'] ?? 'N/A'}"),
              ],
            ),
            const SizedBox(width: 20),
            if (prices.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("7D Trend", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 5),
                  buildSparklineChart(prices, isUp),
                ],
              ),
          ],
        ),
      ),
    ),
  );
}
//   Widget buildCoinTile(dynamic coin) {
//     List<dynamic> prices = (coin['sparkline_in_7d']?['price'] ?? []) as List<dynamic>;
//     double startPrice = prices.isNotEmpty ? prices.first : 0;
//     double endPrice = prices.isNotEmpty ? prices.last : 0;
//     bool isUp = endPrice >= startPrice;

//   return Card(
//   margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//   child: Padding(
//     padding: const EdgeInsets.all(10.0),
//     child: Row(
//       crossAxisAlignment: CrossAxisAlignment.start,  // <-- change from center to start
//       children: [
//         Image.network(
//           coin['image'],
//           width: 40,
//           height: 40,
//           errorBuilder: (context, error, stackTrace) {
//             return const Icon(Icons.error, size: 40);
//           },
//         ),
//         const SizedBox(width: 10),
//         Expanded(  // <-- make sure this wraps the text column
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "${coin['name']} (${coin['symbol'].toUpperCase()})",
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               Text("Price: \$${coin['current_price'] ?? 'N/A'}"),
//               Text("24h Change: ${coin['price_change_percentage_24h']?.toStringAsFixed(2) ?? 'N/A'}%"),
//               Text("7d Change: ${coin['price_change_percentage_7d_in_currency']?.toStringAsFixed(2) ?? 'N/A'}%"),
//               Text("Market Cap: \$${coin['market_cap'] ?? 'N/A'}"),
//               Text("Rank: #${coin['market_cap_rank'] ?? 'N/A'}"),
//             ],
//           ),
//         ),
//         if (prices.isNotEmpty)
//           SizedBox(
//             width: 100,  // <-- give a fixed width to prevent squeezing others
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const Text("7D Trend", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
//                 const SizedBox(height: 5),
//                 buildSparklineChart(prices, isUp),
//               ],
//             ),
//           ),
//       ],
//     ),
//   ),
// );
// }


  Widget buildSparklineChart(List<dynamic> sparklineData, bool isUp) {
    List<FlSpot> spots = sparklineData
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), (entry.value as num).toDouble()))
        .toList();

    return SizedBox(
      height: 60,
      width: 100,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: spots.isNotEmpty ? spots.length.toDouble() - 1 : 0,
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
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        notificationsEnabled: notificationsEnabled,
        title: "Trends",
        onToggleNotifications: () {
          setState(() {
            notificationsEnabled = !notificationsEnabled;
          });
        },
      ),
      drawer: CustomDrawer(
       
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF388E3C)))
            : detailedCoins.isEmpty
                ? const Center(child: Text("No coin data available"))
                : ListView(
                    padding: const EdgeInsets.only(bottom: 20),
                    children: [
//     LayoutBuilder(
//   builder: (context, constraints) {
//     bool isMobile = constraints.maxWidth < 600;  // You can adjust this breakpoint

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       child: isMobile
//           // Mobile Layout
//           ? Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Heading on top for mobile
//                 const Text(
//                   "Digital Currensee",
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontStyle: FontStyle.italic,
//                     color: Color(0xFF388E3C),
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 // Toggle Buttons below the heading
//                 ToggleButtons(
//                   isSelected: [selectedIndex == 0, selectedIndex == 1],
//                   onPressed: (index) {
//                     setState(() {
//                       selectedIndex = index;
//                     });
//                     if (index == 1) {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => MarketNewsPage()),
//                       );
//                     }
//                   },
//                   selectedColor: Colors.white,
//                   selectedBorderColor: Colors.green,
//                   fillColor: Colors.green,
//                   color: Colors.black,
//                   borderRadius: BorderRadius.circular(8),
//                   constraints: const BoxConstraints(
//                     minHeight: 40, // Adjust for mobile button height
//                     minWidth: 100, // Adjust for mobile button width
//                   ),
//                   children: const [
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 15),
//                       child: Text('Coins'),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 15),
//                       child: Text('News'),
//                     ),
//                   ],
//                 ),
//               ],
//             )
//           // Desktop or larger screen layout
//           : Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 // Toggle Buttons on the left for larger screens
//                 Flexible(
//                   flex: 2,
//                   child: ToggleButtons(
//                     isSelected: [selectedIndex == 0, selectedIndex == 1],
//                     onPressed: (index) {
//                       setState(() {
//                         selectedIndex = index;
//                       });
//                       if (index == 1) {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => MarketNewsPage()),
//                         );
//                       }
//                     },
//                     selectedColor: Colors.white,
//                     selectedBorderColor: Colors.green,
//                     fillColor: Colors.green,
//                     color: Colors.black,
//                     borderRadius: BorderRadius.circular(8),
//                     constraints: const BoxConstraints(
//                       minHeight: 40, // Adjust button size for desktop
//                       minWidth: 120,
//                     ),
//                     children: const [
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 15),
//                         child: Text('Coins'),
//                       ),
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 15),
//                         child: Text('News'),
//                       ),
//                     ],
//                   ),
//                 ),
//                 // Heading on the right side for larger screens
//                 Flexible(
//                   flex: 1,
//                   child: FittedBox(
//                     fit: BoxFit.scaleDown,
//                     alignment: Alignment.centerRight,
//                     child: const Text(
//                       "Digital Currensee",
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontStyle: FontStyle.italic,
//                         color: Color(0xFF388E3C),
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//     );
//   },
// ),
 LayoutBuilder(
  builder: (context, constraints) {
    bool isMobile = constraints.maxWidth < 400;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Toggle Buttons (left side, responsive)
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ToggleButtons(
                isSelected: [selectedIndex == 0, selectedIndex == 1],
                onPressed: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                  if (index == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MarketNewsPage()),
                    );
                  }
                },
                selectedColor: Colors.white,
                selectedBorderColor: Colors.green,
                fillColor: Colors.green,
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                constraints: const BoxConstraints(
                  minHeight: 32,
                  minWidth: 60,
                ),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text('Coins'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text('News'),
                  ),
                ],
              ),
            ),
          ),

          // Heading (right side, fixed position)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.newspaper_rounded,
                color: Color.fromARGB(255, 1, 19, 31),
              ),
              SizedBox(width: 4),
              Text(
                "Crypto",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Color.fromARGB(255, 4, 107, 26),
                  overflow: TextOverflow.ellipsis,
                  shadows: [
                    Shadow(
                      offset: Offset(1.5, 1.5),
                      blurRadius: 3.0,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  },
),


                      buildMarketAnalysis(),
                      ...detailedCoins.map((coin) => buildCoinTile(coin)).toList(),
                    ],
                           ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 0),
    );
  }
}
