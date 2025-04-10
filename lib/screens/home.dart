// import 'package:flutter/material.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   TextEditingController amountController = TextEditingController();

//   String fromCurrency = 'USD';
//   String toCurrency = 'PKR';
//   String result = '';

//   // Comprehensive list of currencies with name, symbol, and country
//   List<Map<String, String>> currencies = [
//     {'name': 'USD', 'symbol': '\$', 'fullName': 'United States Dollar', 'country': 'United States'},
//     {'name': 'PKR', 'symbol': '₨', 'fullName': 'Pakistani Rupee', 'country': 'Pakistan'},
//     {'name': 'EUR', 'symbol': '€', 'fullName': 'Euro', 'country': 'European Union'},
//     {'name': 'INR', 'symbol': '₹', 'fullName': 'Indian Rupee', 'country': 'India'},
//     {'name': 'GBP', 'symbol': '£', 'fullName': 'British Pound', 'country': 'United Kingdom'},
//     {'name': 'JPY', 'symbol': '¥', 'fullName': 'Japanese Yen', 'country': 'Japan'},
//     {'name': 'CAD', 'symbol': '\$', 'fullName': 'Canadian Dollar', 'country': 'Canada'},
//     {'name': 'AUD', 'symbol': '\$', 'fullName': 'Australian Dollar', 'country': 'Australia'},
//     {'name': 'CNY', 'symbol': '¥', 'fullName': 'Chinese Yuan', 'country': 'China'},
//     {'name': 'BRL', 'symbol': '\$', 'fullName': 'Brazilian Real', 'country': 'Brazil'},
//     {'name': 'MXN', 'symbol': '\$', 'fullName': 'Mexican Peso', 'country': 'Mexico'},
//     {'name': 'CHF', 'symbol': 'CHF', 'fullName': 'Swiss Franc', 'country': 'Switzerland'},
//     {'name': 'RUB', 'symbol': '₽', 'fullName': 'Russian Ruble', 'country': 'Russia'},
//     {'name': 'SGD', 'symbol': '\$', 'fullName': 'Singapore Dollar', 'country': 'Singapore'},
//     {'name': 'ZAR', 'symbol': 'R', 'fullName': 'South African Rand', 'country': 'South Africa'},
//     {'name': 'KRW', 'symbol': '₩', 'fullName': 'South Korean Won', 'country': 'South Korea'},
//     {'name': 'SEK', 'symbol': 'kr', 'fullName': 'Swedish Krona', 'country': 'Sweden'},
//     {'name': 'NOK', 'symbol': 'kr', 'fullName': 'Norwegian Krone', 'country': 'Norway'},
//     {'name': 'TRY', 'symbol': '₺', 'fullName': 'Turkish Lira', 'country': 'Turkey'},
//     {'name': 'AED', 'symbol': 'د.إ', 'fullName': 'United Arab Emirates Dirham', 'country': 'UAE'},
//     {'name': 'DKK', 'symbol': 'kr', 'fullName': 'Danish Krone', 'country': 'Denmark'},
//     {'name': 'THB', 'symbol': '฿', 'fullName': 'Thai Baht', 'country': 'Thailand'},
//     {'name': 'PLN', 'symbol': 'zł', 'fullName': 'Polish Zloty', 'country': 'Poland'},
//     {'name': 'MYR', 'symbol': 'RM', 'fullName': 'Malaysian Ringgit', 'country': 'Malaysia'},
//     {'name': 'VND', 'symbol': '₫', 'fullName': 'Vietnamese Dong', 'country': 'Vietnam'},
//     {'name': 'IDR', 'symbol': 'Rp', 'fullName': 'Indonesian Rupiah', 'country': 'Indonesia'},
//   ];

//   // Function to simulate conversion (for demo purpose)
//   double convertCurrency(double amount, String from, String to) {
//     // Hardcoded conversion rates for demonstration. In a real app, you'd get this data dynamically from an API.
//     Map<String, double> rates = {
//       'USD-PKR': 180.0,
//       'USD-EUR': 0.85,
//       'USD-INR': 75.0,
//       'USD-GBP': 0.75,
//       'USD-JPY': 110.0,
//       'USD-MXN': 20.0, 
//       'USD-CHF': 0.91,
//       'USD-RUB': 75.0,
//       'USD-SGD': 1.36,
//       'USD-ZAR': 14.5,
//       'USD-KRW': 1200.0,
//       'USD-SEK': 8.5,
//       'USD-NOK': 8.9,
//       'USD-TRY': 18.5,
//       'USD-AED': 3.67,
//       'USD-DKK': 6.5,
//       'USD-THB': 34.0,
//       'USD-PLN': 4.3,
//       'USD-MYR': 4.2,
//       'USD-VND': 23000.0,
//       'USD-IDR': 15000.0,
//     };

//     String key = '$from-$to';
//     if (rates.containsKey(key)) {
//       return amount * rates[key]!;
//     }
//     return 0.0;
//   }

//   // Function to filter currencies based on search input
//   List<Map<String, String>> filterCurrencies(String query) {
//     return currencies.where((currency) {
//       return currency['fullName']!.toLowerCase().contains(query.toLowerCase());
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Currency Converter"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               "Welcome to Currensee! 💱",
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 30),
//             TextField(
//               controller: amountController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 label: Text("Amount"),
//                 hintText: "Enter Amount",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 30),
//             Row(
//               children: [
//                 Expanded(
//                   child: TypeAheadFormField<Map<String, String>>(
//                     textFieldConfiguration: TextFieldConfiguration(
//                       decoration: InputDecoration(
//                         labelText: "From",
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                     suggestionsCallback: (pattern) {
//                       return filterCurrencies(pattern);
//                     },
//                     itemBuilder: (context, Map<String, String> currency) {
//                       return ListTile(
//                         title: Text(
//                           '${currency['fullName']} (${currency['symbol']})',
//                         ),
//                       );
//                     },
//                     onSuggestionSelected: (Map<String, String> suggestion) {
//                       setState(() {
//                         fromCurrency = suggestion['name']!;
//                       });
//                     },
//                     validator: (value) {
//                       if (value == null) return 'Please select a currency';
//                       return null;
//                     },
//                   ),
//                 ),
//                 SizedBox(width: 20),
//                 Expanded(
//                  child: TypeAheadFormField<Map<String, String>>(
//                     textFieldConfiguration: TextFieldConfiguration(
//                       decoration: InputDecoration(
//                         labelText: "To",
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                     suggestionsCallback: (pattern) {
//                       return filterCurrencies(pattern);
//                     },
//                     itemBuilder: (context, Map<String, String> currency) {
//                       return ListTile(
//                         title: Text(
//                           '${currency['fullName']} (${currency['symbol']})',
//                         ),
//                       );
//                     },
//                     onSuggestionSelected: (Map<String, String> suggestion) {
//                       setState(() {
//                         toCurrency = suggestion['name']!;
//                       });
//                     },
//                     validator: (value) {
//                       if (value == null) return 'Please select a currency';
//                       return null;
//                     },
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: () {
//                 double amount = double.tryParse(amountController.text) ?? 0.0;
//                 if (amount > 0) {
//                   double convertedAmount = convertCurrency(amount, fromCurrency, toCurrency);
//                   setState(() {
//                     result = '$amount ${currencies.firstWhere((currency) => currency['name'] == fromCurrency)['symbol']} = $convertedAmount ${currencies.firstWhere((currency) => currency['name'] == toCurrency)['symbol']}';
//                   });
//                 } else {
//                   setState(() {
//                     result = 'Please enter a valid amount.';
//                   });
//                 }
//               },
//               child: Text("Convert"),
//             ),
//             SizedBox(height: 20),
//             Text(
//               result.isEmpty ? "Result will appear here." : result,
//               style: TextStyle(fontSize: 20),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
