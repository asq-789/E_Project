import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Articlespage extends StatefulWidget {
  const Articlespage({super.key});
  @override
  State<Articlespage> createState() => _ProductAPIState();
}

class _ProductAPIState extends State<Articlespage> {
getProducts()async{
  var url=Uri.parse('https://api.marketaux.com/v1/news/all?countries=us&filter_entities=true&limit=10&published_after=2025-04-16T04:25&api_token=aUAqtGqWX1ZWkfoMD9ChpNR1HraCK6TxYc1qyqNc');
  var response=await http.get(url);
  // print(response.body);
  return jsonDecode(response.body);
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar:   AppBar(
        title: Text("Products from API"),
      ),
   body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: FutureBuilder(
          future: getProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              // Ensuring the data is correctly cast to a Map<String, dynamic>
              var data = snapshot.data as Map<String, dynamic>;
              var products = data['data'] as List<dynamic>;
              return ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  var product = products[index];
                  return ListTile(
                    title: Text(product['title'].toString()),
                    subtitle: Text(product['description'].toString()),
                   // leading: Image.network(product['images'][0]),
                  );
                },
              );
            } else {
              return Center(child: Text("No data available"));
            }
          },
        ),
      ),

    );
  }
}