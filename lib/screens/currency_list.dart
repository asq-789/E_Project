import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CurrencyList extends StatefulWidget {
  const CurrencyList({super.key});

  @override
  State<CurrencyList> createState() => _CurrencyListState();
}

class _CurrencyListState extends State<CurrencyList> {
  TextEditingController searchController = TextEditingController();
 late Future<Map<String, dynamic>> _currencyFuture;

  @override
  void initState() {
    super.initState();
    _currencyFuture = getData();
  }
  Future<Map<String, dynamic>> getData() async {
    var url = Uri.parse(
        'https://v6.exchangerate-api.com/v6/6aa43d570c95f0577517c38d/latest/USD');
    var response = await http.get(url);
    var data = jsonDecode(response.body);
    return data['conversion_rates'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){}, icon: Icon(Icons.menu, color:Colors.white)),
          backgroundColor: const Color(0xFF388E3C), 
        title: Text("Currensee",style: TextStyle(color: Colors.white),),
        
      ),
      body: Padding(
        padding:  EdgeInsets.symmetric(horizontal: 20),
        child: FutureBuilder<Map<String, dynamic>>(
        future: _currencyFuture,

          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return  Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              var data = snapshot.data!;
              var currencies = data.entries.toList();

              var filteredCurrencies = currencies.where((entry) {
                final search = searchController.text.toLowerCase();
                return entry.key.toLowerCase().contains(search);
              }).toList();

              return Column(
                children: [
                  SizedBox(height: 20),
                  TextFormField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: "Search",
                     border: OutlineInputBorder(
  borderRadius: BorderRadius.horizontal(
    left: Radius.circular(12),
    right: Radius.circular(12),
  ),
),
                     prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {}); 
                    },
                  ),
                 SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredCurrencies.length,
                      itemBuilder: (context, index) {
                        var currency = filteredCurrencies[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                   shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
                            child: ListTile(
                              leading: Text(currency.key,style: TextStyle(fontWeight: FontWeight.bold),),
                              title: Text(
                                 currency.value.toString(),),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              );
            } else {
              return  Center(child: Text("No data found"));
            }
          },
        ),
      ),
    );
  }
}
