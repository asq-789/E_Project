import 'package:currensee/components/bottom_navbar.dart';
import 'package:currensee/components/my_appbar.dart';
import 'package:currensee/screens/TrendsPage.dart';
import 'package:flutter/material.dart';

// Articles and news
final List<Map<String, dynamic>> marketNews = [
  {
    "title": "USD to EUR Exchange Rate Drops",
    "description": "The USD has seen a slight drop against the Euro. Experts predict this trend to continue in the upcoming weeks.",
    "currency": "USD",
    "rate": 0.92,
    "date": "2025-04-17"
  },
  {
    "title": "GBP Gains Against JPY",
    "description": "The British Pound has strengthened against the Japanese Yen due to recent economic reports out of the UK.",
    "currency": "GBP",
    "rate": 154.25,
    "date": "2025-04-17"
  },
  {
    "title": "AUD Steady Amidst Economic Stability",
    "description": "The Australian Dollar has maintained stability, with analysts predicting minimal fluctuation in the next quarter.",
    "currency": "AUD",
    "rate": 1.30,
    "date": "2025-04-17"
  },
  {
    "title": "CAD Hits 1.35 Against USD",
    "description": "The Canadian Dollar has strengthened against the USD after a surge in oil prices. Experts are hopeful about further gains.",
    "currency": "CAD",
    "rate": 1.35,
    "date": "2025-04-16"
  },
  {
    "title": "JPY to GBP Exchange Rate Fluctuates",
    "description": "The Japanese Yen has experienced volatility against the British Pound due to geopolitical tensions in Asia.",
    "currency": "JPY",
    "rate": 154.75,
    "date": "2025-04-16"
  },
  {
    "title": "NZD Strengthens Amid Positive Economic Data",
    "description": "The New Zealand Dollar has risen after reports of positive economic growth. Analysts expect further gains in the next quarter.",
    "currency": "NZD",
    "rate": 1.45,
    "date": "2025-04-15"
  },
  {
    "title": "CHF Remains Strong Despite Global Uncertainty",
    "description": "The Swiss Franc remains strong against major currencies, with investors seeking safety amidst global economic uncertainty.",
    "currency": "CHF",
    "rate": 0.95,
    "date": "2025-04-15"
  },
  {
    "title": "EUR/USD Breaks 1.10 Mark",
    "description": "The Euro has broken the 1.10 mark against the USD, continuing its upward trajectory as European economic recovery gains momentum.",
    "currency": "EUR",
    "rate": 1.10,
    "date": "2025-04-14"
  },
  {
    "title": "USD Volatility in Response to Fed's Policy",
    "description": "The USD has seen significant volatility following the Federal Reserve's latest policy announcement regarding interest rates.",
    "currency": "USD",
    "rate": 0.92,
    "date": "2025-04-14"
  },
  {
    "title": "GBP Rises Amid Strong UK Manufacturing Data",
    "description": "The British Pound has gained strength after positive data from the UK manufacturing sector, signaling economic recovery.",
    "currency": "GBP",
    "rate": 1.35,
    "date": "2025-04-13"
  },
  {
    "title": "AUD to USD Exchange Rate Shows Steady Growth",
    "description": "The Australian Dollar has shown steady growth against the USD due to a surge in Australian export demand.",
    "currency": "AUD",
    "rate": 0.65,
    "date": "2025-04-13"
  },
  {
    "title": "BRL Strengthens as Brazil's Economy Shows Improvement",
    "description": "The Brazilian Real has strengthened amid improving economic data out of Brazil. Investors are now more optimistic about the country's future.",
    "currency": "BRL",
    "rate": 5.20,
    "date": "2025-04-12"
  },
  {
    "title": "INR Sees Volatility Amid Election Season",
    "description": "The Indian Rupee has been volatile as the Indian general elections approach, with traders anticipating political uncertainty.",
    "currency": "INR",
    "rate": 74.85,
    "date": "2025-04-12"
  },
  {
    "title": "MXN Rebounds Following Economic Stimulus Package",
    "description": "The Mexican Peso has rebounded following a government announcement of an economic stimulus package aimed at boosting the economy.",
    "currency": "MXN",
    "rate": 18.95,
    "date": "2025-04-11"
  },
  {
    "title": "SEK Declines Against EUR",
    "description": "The Swedish Krona has declined against the Euro after the release of disappointing retail sales data from Sweden.",
    "currency": "SEK",
    "rate": 10.50,
    "date": "2025-04-11"
  },
  {
    "title": "ZAR Continues to Strengthen Amid Positive Mining Data",
    "description": "The South African Rand has continued its upward trajectory, supported by positive mining production data coming out of South Africa.",
    "currency": "ZAR",
    "rate": 18.25,
    "date": "2025-04-10"
  },
  {
    "title": "TRY Faces Decline Amid Political Instability",
    "description": "The Turkish Lira has faced a decline due to ongoing political instability and rising inflation rates in Turkey.",
    "currency": "TRY",
    "rate": 8.50,
    "date": "2025-04-10"
  },
  {
    "title": "HKD Gains After Positive Economic Forecast",
    "description": "The Hong Kong Dollar has strengthened after the government released a more positive-than-expected economic forecast for the region.",
    "currency": "HKD",
    "rate": 7.85,
    "date": "2025-04-09"
  },
  {
    "title": "RUB Weakens Amid Sanctions Concerns",
    "description": "The Russian Ruble has weakened against major currencies due to renewed concerns over international sanctions and global trade tensions.",
    "currency": "RUB",
    "rate": 75.25,
    "date": "2025-04-09"
  },
  {
    "title": "KRW Shows Positive Growth Against USD",
    "description": "The South Korean Won has shown positive growth against the USD following reports of strong export data from South Korea.",
    "currency": "KRW",
    "rate": 1185.50,
    "date": "2025-04-08"
  },
  // Adding 10 more articles
  {
    "title": "JPY Gains Amid Market Recovery",
    "description": "The Japanese Yen has gained strength following a strong market recovery, as investors start taking more risks in Asia.",
    "currency": "JPY",
    "rate": 110.50,
    "date": "2025-04-08"
  },
  {
    "title": "USD Strengthens with US Job Growth Data",
    "description": "The US Dollar has strengthened against major currencies following the release of strong job growth data from the United States.",
    "currency": "USD",
    "rate": 1.0,
    "date": "2025-04-07"
  },
  {
    "title": "EUR Stabilizes as Inflation Concerns Subside",
    "description": "The Euro has stabilized as inflation concerns in the Eurozone show signs of easing, with analysts projecting steady growth.",
    "currency": "EUR",
    "rate": 1.12,
    "date": "2025-04-07"
  },
  {
    "title": "GBP Drops Amid Economic Uncertainty",
    "description": "The British Pound has seen a drop against major currencies as economic uncertainty continues to cloud the UK's recovery.",
    "currency": "GBP",
    "rate": 1.28,
    "date": "2025-04-06"
  },
  {
    "title": "AUD Declines Following Lower Commodity Prices",
    "description": "The Australian Dollar has declined against the USD following a drop in commodity prices, signaling concerns about global trade.",
    "currency": "AUD",
    "rate": 0.70,
    "date": "2025-04-06"
  },
  {
    "title": "CAD Faces Volatility as Oil Prices Fluctuate",
    "description": "The Canadian Dollar has faced volatility as oil prices continue to fluctuate amid concerns about global supply chains.",
    "currency": "CAD",
    "rate": 1.25,
    "date": "2025-04-05"
  },
  {
    "title": "INR Drops Amid Political Tensions",
    "description": "The Indian Rupee has dropped as political tensions rise in India, causing instability in the financial markets.",
    "currency": "INR",
    "rate": 75.50,
    "date": "2025-04-05"
  },
  {
    "title": "RUB Weakens After Drop in Oil Prices",
    "description": "The Russian Ruble has weakened further as global oil prices drop, affecting Russia's major revenue stream.",
    "currency": "RUB",
    "rate": 76.00,
    "date": "2025-04-04"
  },
  {
    "title": "BRL Continues to Rise Amid Economic Reforms",
    "description": "The Brazilian Real has continued to rise following new economic reforms aimed at improving fiscal stability in Brazil.",
    "currency": "BRL",
    "rate": 5.10,
    "date": "2025-04-04"
  }
];


class MarketNewsPage extends StatefulWidget {
  const MarketNewsPage({Key? key}) : super(key: key);

  @override
  State<MarketNewsPage> createState() => _MarketNewsPageState();
}

class _MarketNewsPageState extends State<MarketNewsPage> {
  bool isLoading = true;
  int selectedIndex = 0; // 0 for Articles, 1 for Trends
  bool notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Automatically navigate to Trendspage if Trends tab is selected
    if (selectedIndex == 1) {
      Future.delayed(Duration.zero, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Trendspage()),
        );
      });
    }

    return Scaffold(
      appBar: CustomAppBar(
        notificationsEnabled: notificationsEnabled,
        title: "Market News",
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
      body: Column(
        children: [
        LayoutBuilder(
  builder: (context, constraints) {
    bool isMobile = constraints.maxWidth < 400;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Heading
                Row(
                  children: const [
                    Icon(
                      Icons.newspaper_rounded,
                      color: Color.fromARGB(255, 1, 19, 31),
                    ),
                    SizedBox(width: 4),
                    Text(
                      "Top Stories",
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
                const SizedBox(height: 10),
                // Toggle Buttons
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ToggleButtons(
                    isSelected: [selectedIndex == 0, selectedIndex == 1],
                    onPressed: (index) {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    selectedColor: Colors.white,
                    selectedBorderColor: Colors.green,
                    fillColor: Colors.green,
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text('News'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text('Trends'),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Toggle Buttons
                Flexible(
                  flex: 2,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ToggleButtons(
                      isSelected: [selectedIndex == 0, selectedIndex == 1],
                      onPressed: (index) {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      selectedColor: Colors.white,
                      selectedBorderColor: Colors.green,
                      fillColor: Colors.green,
                      color: Colors.black,
                       borderRadius: BorderRadius.circular(6),
  constraints: const BoxConstraints(
    minHeight: 32,
    minWidth: 60,
  ),
                    //  borderRadius: BorderRadius.circular(8),
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text('News'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text('Trends'),
                        ),
                      ],
                    ),
                  ),
                ),

                // Heading
                Flexible(
                  flex: 1,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Row(
                      children: const [
                        Icon(
                          Icons.newspaper_rounded,
                          color: Color.fromARGB(255, 1, 19, 31),
                        ),
                        SizedBox(width: 4),
                        Text(
                          "Top Stories",
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
                  ),
                ),
              ],
            ),
    );
  },
),



          // Render Articles
          selectedIndex == 0
              ? Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: marketNews.length,
                          itemBuilder: (context, index) {
                            final news = marketNews[index];
                           return Card(
  margin: const EdgeInsets.all(10),
  elevation: 5,
  color: Colors.white,
  child: Padding(
    padding: const EdgeInsets.all(12.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // News Title
        Text(
          news['title'] ?? 'No Title',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineLarge?.color ?? Colors.black,
          ),
        ),
        const SizedBox(height: 8),

        // News Description
        Text(
          news['description'] ?? 'No description',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),

        // Rate, Currency, and Date
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rate: ${news['rate'] ?? 'N/A'}',
              style: const TextStyle(color: Colors.redAccent),
            ),
            Text(
              'Currency: ${news['currency'] ?? 'N/A'}',
              style: const TextStyle(color: Colors.blue),
            ),
            Text(
              'Date: ${news['date'] ?? 'N/A'}',
              style: const TextStyle(color: Colors.black87),
            ),
          ],
        ),
      ],
    ),
  ),
);

                          },
                        ),
                )
              : Container(), // This part won't be visible since it's handled by navigation directly to Trendspage
        ],
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 0), // Home
    );
  }
}

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      primaryColor: Colors.blue, // Set the primary color for the app
      scaffoldBackgroundColor: Color(0xFFF1F1F1), // Soft light gray background
      textTheme: TextTheme(
        headlineLarge: TextStyle(color: Colors.black), // Text style for titles
        bodyMedium: TextStyle(color: Colors.black87), // Body text style
      ),
      cardColor: Colors.white, // Card background color
      buttonTheme: ButtonThemeData(buttonColor: Colors.blue), // Button color
    ),
    home: MarketNewsPage(),
  ));
}