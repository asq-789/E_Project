import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
String formatDate(String dateStr) {
  try {
    final parts = dateStr.split(',')[1].trim().split(' ');
    return "${parts[0]} ${parts[1]} ${parts[2]}"; // "13 Apr 2025"
  } catch (e) {
    return dateStr; // fallback
  }
}

class CurrencyList extends StatefulWidget {
  const CurrencyList({super.key});

  @override
  State<CurrencyList> createState() => _CurrencyListState();
}

class _CurrencyListState extends State<CurrencyList> {
  TextEditingController searchController = TextEditingController();
String lastUpdated = '';
String nextUpdate = '';

 late Future<Map<String, dynamic>> _currencyFuture;


  @override
  void initState() {
    super.initState();
    _currencyFuture = getData();
  }
  Future<Map<String, dynamic>> getData() async {
    var url = Uri.parse(
        'https://v6.exchangerate-api.com/v6/6aa43d570c95f0577517c38d/latest/PKR');
    var response = await http.get(url);
    var data = jsonDecode(response.body);
   
 setState(() {
  lastUpdated = formatDate(data['time_last_update_utc'] ?? '');
  nextUpdate = formatDate(data['time_next_update_utc'] ?? '');
});



    return data['conversion_rates'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){}, icon: Icon(Icons.menu, color:Colors.white)),
          backgroundColor: const Color(0xFF388E3C), 
        title: Text("All Currencies",style: TextStyle(color: Colors.white),),
        
      ),
      body: Padding(
        padding:  EdgeInsets.symmetric(horizontal: 20),
        child: FutureBuilder<Map<String, dynamic>>(
        future: _currencyFuture,

          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return  Center(child: CircularProgressIndicator(color: Color(0xFF388E3C)));
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
                             elevation: 3, // adds slight shadow
  shadowColor: Colors.green.shade100,
                   shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
Text(currency.key,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
SizedBox(height: 7,),
 Text(  "1 USD = ${currency.value.toString()} ${currency.key}", style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[700])),
                   SizedBox(height: 5),
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
Text("Last Updated: $lastUpdated", style: TextStyle(fontSize: 10, color: Colors.grey[600])),
 SizedBox(width: 40),
Text("Next Update: $nextUpdate", style: TextStyle(fontSize: 10, color: Colors.grey[600])),

                    ],
                   )

                                    ],
                                  ),
 IconButton(
  icon: Icon(Icons.favorite_border),
  onPressed: () {
    // for button press
  },
),

                                ],
                               
                              
                              ),
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
