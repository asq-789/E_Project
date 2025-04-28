import 'dart:convert';
import 'package:currensee/components/bottom_navbar.dart';
import 'package:currensee/components/my_appbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

String formatDate(String dateStr) {
  try {
    final parts = dateStr.split(',')[1].trim().split(' ');
    return "${parts[0]} ${parts[1]} ${parts[2]}"; 
  } catch (e) {
    return dateStr; 
  }
}

List<String> globalLikedCurrencies = [];

class CurrencyList extends StatefulWidget {
  const CurrencyList({super.key});

  @override
  State<CurrencyList> createState() => _CurrencyListState();
}

class _CurrencyListState extends State<CurrencyList> {
  TextEditingController searchController = TextEditingController();
  String baseCurrency = ""; 
  String lastUpdated = '';
  String nextUpdate = '';
  bool notificationsEnabled = false;

  Future<Map<String, dynamic>> fetchCurrencyData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return {};

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!doc.exists || !doc.data()!.containsKey('baseCurrency')) return {};

    final currency = doc['baseCurrency'];
    baseCurrency = currency;

    final url = Uri.parse('https://v6.exchangerate-api.com/v6/a2c638780d6ad08604e564f8/latest/$currency');
    final response = await http.get(url);
    final data = jsonDecode(response.body);

    lastUpdated = formatDate(data['time_last_update_utc'] ?? '');
    nextUpdate = formatDate(data['time_next_update_utc'] ?? '');

    final likedSnap = await FirebaseFirestore.instance
        .collection('liked_currencies')
        .doc(uid)
        .collection('currencies')
        .get();

    likedCurrencies = likedSnap.docs.map((doc) => doc.id).toList();
    globalLikedCurrencies = likedCurrencies;

    return data['conversion_rates'];
  }

  List<String> likedCurrencies = globalLikedCurrencies;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        notificationsEnabled: notificationsEnabled,
        title: "Currency List",
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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: FutureBuilder<Map<String, dynamic>>(
          future: fetchCurrencyData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null) {
              return Center(child: CircularProgressIndicator(color: Color(0xFF388E3C)));
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              var data = snapshot.data!;
              var currencies = data.entries.toList();

              var filteredCurrencies = currencies.where((entry) {
                final search = searchController.text.toLowerCase();
                return entry.key.toLowerCase().contains(search);
              }).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Search",
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        prefixIcon: Icon(Icons.search, color: Color(0xFF388E3C)),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF388E3C)),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredCurrencies.length,
                      itemBuilder: (context, index) {
                        var currency = filteredCurrencies[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            elevation: 3,
                            shadowColor: Colors.green.shade100,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          currency.key,
                                          style: TextStyle(
                                              fontSize: 19,
                                              letterSpacing: 1,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 7),
                                        Text(
                                          "1 $baseCurrency = ${currency.value.toString()} ${currency.key}",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF388E3C),
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 7),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "Last Updated: $lastUpdated",
                                                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                "Next Update: $nextUpdate",
                                                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      likedCurrencies.contains(currency.key)
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: likedCurrencies.contains(currency.key)
                                          ? Color(0xFF388E3C)
                                          : null,
                                    ),
                                    onPressed: () async {
                                      final user = FirebaseAuth.instance.currentUser;
                                      if (user == null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("Please log in first")));
                                        return;
                                      }

                                      final currencyCode = currency.key;
                                      final value = currency.value;
                                      final isLiked = likedCurrencies.contains(currencyCode);

                                      setState(() {
                                        if (isLiked) {
                                          globalLikedCurrencies.remove(currencyCode);
                                        } else {
                                          globalLikedCurrencies.add(currencyCode);
                                        }
                                      });

                                      final docRef = FirebaseFirestore.instance
                                          .collection('liked_currencies')
                                          .doc(user.uid)
                                          .collection('currencies')
                                          .doc(currencyCode);

                                      if (isLiked) {
                                        await docRef.delete();
                                      } else {
                                        await docRef.set({
                                          'name': currencyCode,
                                          'value': value.toString(),
                                          'symbol': baseCurrency,
                                          'lastUpdated': lastUpdated,
                                          'nextUpdate': nextUpdate,
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            } else {
              return Center(child: Text("No data found"));
            }
          },
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 2),
    );
  }
}
