import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

final List<Map<String, dynamic>> marketTrends = [
  {
    "coin": "Bitcoin",
    "status": "Top",
    "price": 55000,
    "change": 5.4,
    "description": "Bitcoin continues to dominate the market with positive trends.",
    "date": "2025-04-17"
  },
  {
    "coin": "Ethereum",
    "status": "Top",
    "price": 3000,
    "change": 3.1,
    "description": "Ethereum's price continues to rise as more institutions adopt blockchain technology.",
    "date": "2025-04-17"
  },
  {
    "coin": "Dogecoin",
    "status": "Low",
    "price": 0.5,
    "change": -2.1,
    "description": "Dogecoin has faced a drop in value due to low market sentiment.",
    "date": "2025-04-17"
  },
  {
    "coin": "Ripple (XRP)",
    "status": "Low",
    "price": 1.0,
    "change": -4.5,
    "description": "XRP's value has declined due to ongoing legal issues and market uncertainty.",
    "date": "2025-04-16"
  },
  // Add more market trend data here...
];

class Trendspage extends StatefulWidget {
  const Trendspage({Key? key}) : super(key: key);

  @override
  State<Trendspage> createState() => _MarketNewsPageState();
}

class _MarketNewsPageState extends State<Trendspage> {
  bool isLoading = true;
  int selectedIndex = 0; // 0 for Articles, 1 for Trends

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  // Generate sample data for chart (price changes over time for a specific coin)
  List<FlSpot> getChartData() {
    return [
      FlSpot(0, 5000),
      FlSpot(1, 5100),
      FlSpot(2, 5200),
      FlSpot(3, 5300),
      FlSpot(4, 5400),
      FlSpot(5, 5500),
      FlSpot(6, 5400),
      FlSpot(7, 5500),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cryptocurrency Market Trends'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          // Toggle Buttons for Articles and Trends
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ToggleButtons(
              isSelected: [selectedIndex == 0, selectedIndex == 1],
              onPressed: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Articles'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Trends'),
                ),
              ],
            ),
          ),

          // Display content based on selected index
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : selectedIndex == 0
                    ? ListView.builder(
                        itemCount: 5, // Adjust based on your article data
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.all(10),
                            elevation: 5,
                            child: ListTile(
                              title: Text(
                                "Article Title ${index + 1}",
                                style: const TextStyle(fontSize: 18),
                              ),
                              subtitle: const Text(
                                  "Article description goes here."),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Article Title'),
                                      content: const Text('Article content here.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        },
                      )
                    : ListView.builder(
                        itemCount: marketTrends.length,
                        itemBuilder: (context, index) {
                          final trend = marketTrends[index];
                          return Card(
                            margin: const EdgeInsets.all(10),
                            elevation: 5,
                            child: ListTile(
                              title: Text(
                                trend['coin'],
                                style: const TextStyle(fontSize: 18),
                              ),
                              subtitle: Text(
                                "${trend['description']} | Price: \$${trend['price']} | Change: ${trend['change']}%",
                              ),
                              trailing: Icon(
                                trend['status'] == "Top"
                                    ? Icons.trending_up
                                    : Icons.trending_down,
                                color: trend['status'] == "Top"
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(trend['coin']),
                                      content: Text(trend['description']),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
          // Chart Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Price Trend for Bitcoin',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(show: true),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: getChartData(),
                    isCurved: true,
                    color: Colors.blueAccent,
                    belowBarData: BarAreaData(show: true),
                  ),
                ],
              ),
            ),
          ),
          // Analysis Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Market Analysis',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'The market for Bitcoin is currently on an upward trend with institutional investors showing greater interest in adopting cryptocurrency as an asset class. Ethereum is also gaining ground, especially with the increasing number of decentralized finance projects being built on its blockchain. However, coins like Dogecoin and XRP are facing downward pressure due to market volatility and regulatory concerns.',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Trendspage(),
  ));
}
