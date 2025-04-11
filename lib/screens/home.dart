import 'dart:convert';


import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
String fromCurrency ='USD';
String toCurrency = 'PKR';
double rate =0.0;
double total =0.0;
TextEditingController amountController = TextEditingController();
List<String> currencies = []; 


@override
void initState(){
  super.initState();
  getcurrencies();
}

Future<void> getcurrencies()async{
  var url = Uri.parse('https://v6.exchangerate-api.com/v6/6aa43d570c95f0577517c38d/latest/USD');
  var response = await http.get(url);
    var data = jsonDecode(response.body);
setState(() {
  currencies = (data['conversion_rates'] as Map<String,dynamic>).keys.toList();
  
});

}
Future<void> getRate()async{
  var url = Uri.parse('https://v6.exchangerate-api.com/v6/6aa43d570c95f0577517c38d/latest/$fromCurrency');
  var response = await http.get(url);
      var data = jsonDecode(response.body);
setState(() {
  rate = data["conversion_rates"][toCurrency];
});

}
getRateAndConvert()async{
if(amountController.text.isEmpty) return;
double amount =double.tryParse(amountController.text) ?? 0.0;
var url = Uri.parse('https://v6.exchangerate-api.com/v6/6aa43d570c95f0577517c38d/latest/$fromCurrency');
var response =await http.get(url);
var data =jsonDecode(response.body);
setState(() {
rate = data['conversion_rates'][toCurrency];
total = amount * rate;

});
}
void swapCurrencies(){
  setState(() {
    String temp = fromCurrency;
    fromCurrency = toCurrency;
    toCurrency = temp;
    total = 0.0;
    rate = 0.0;
  });
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
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20,),
                Text("Welcome to Currensee! 💱",style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),)
            , SizedBox(height: 30,),
             TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                label: Text("Amount"),
                    hintText: "Enter Amount",
                    border: OutlineInputBorder(),
              ),
             
             ),
             SizedBox(height: 30,),
             Row(
              children: [
                Expanded(
                child: DropdownButtonFormField<String>(
                  value: currencies.contains(fromCurrency) ? fromCurrency : null,
                  decoration: InputDecoration(
                  label: Text("From"),
                        border: OutlineInputBorder(),
                  ),
               items:  currencies.map((currency){
                    return DropdownMenuItem(
            value: currency,
            child: Text(currency));
                }).toList(),
                onChanged: (newValue){
                  setState(() {
                    fromCurrency = newValue!;
               
                  });
                }),
                    
                ),
                    
                    
                    Icon(Icons.swap_horiz, size:40),
                                     Expanded(
                                      child: DropdownButtonFormField<String>(
            value: currencies.contains(toCurrency) ? toCurrency : null,
            decoration: InputDecoration(
              label: Text("To"),
              border: OutlineInputBorder(),
            ),
            items: currencies.map((currency){
                     return DropdownMenuItem(
            value: currency,
            child: Text(currency));
            }).toList(),
          onChanged: (newValue){
  setState(() {
    toCurrency = newValue!;
  });
}),
             )  
              ],
             ),
              SizedBox(height: 30),
   
ElevatedButton(
  onPressed: getRateAndConvert,
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF388E3C),
  ),
  child: Text("Convert", style: TextStyle(fontSize: 16, color: Colors.white)),
),

SizedBox(height: 20),


if (rate != 0.0) ...[
  Text("Rate: $rate", style: TextStyle(fontSize: 20)),
  SizedBox(height: 10),
  Text('Total: ${total.toStringAsFixed(3)}', style: TextStyle(fontSize: 30)),
],

             
              ],
            ),
          ),
        ),
      
    );
  }
}