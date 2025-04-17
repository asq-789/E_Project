import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? username, email, phone, baseCurrency;
  bool isLoading = true;

 Map<String, dynamic> currencyMap = {};
List<String> currencyList = [];

@override
void initState() {
  super.initState();
  fetchUserData();
  getCurrencyData(); // fetch currency list
}

Future<void> getCurrencyData() async {
  var url = Uri.parse('https://v6.exchangerate-api.com/v6/6aa43d570c95f0577517c38d/latest/USD');
  var response = await http.get(url);
  var data = jsonDecode(response.body);

  setState(() {
    currencyMap = Map<String, dynamic>.from(data['conversion_rates']);
    currencyList = currencyMap.keys.toList();
  });
}


  Future<void> fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        setState(() {
          username = userData?['username'];
          email = userData?['email'];
          phone = userData?['phone'];
          baseCurrency = userData?['baseCurrency'];
          isLoading = false;
        });
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

 void showEditDialog(String field, String currentValue) async {
  TextEditingController controller = TextEditingController(text: currentValue);

 if (field == 'baseCurrency') {
  String selectedCurrency = currentValue;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Currency'),
        content: DropdownButtonFormField<String>(
          value: selectedCurrency,
          items: currencyList.map((currency) {
            return DropdownMenuItem<String>(
              value: currency,
              child: Text(currency),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedCurrency = value!;
            });
          },
          decoration: InputDecoration(
            labelText: "Select new currency",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid != null) {
                await FirebaseFirestore.instance.collection('users').doc(uid).update({
                  'baseCurrency': selectedCurrency,
                });

                setState(() {
                  baseCurrency = selectedCurrency;
                });
              }

              Navigator.pop(context); // Close dialog
            },
            child: Text('Update'),
          ),
        ],
      );
    },
  );
}

else {
    // For username, email, phone
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit $field'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: "New $field",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final uid = FirebaseAuth.instance.currentUser?.uid;
                if (uid != null) {
                  await FirebaseFirestore.instance.collection('users').doc(uid).update({
                    field: controller.text.trim(),
                  });

                  setState(() {
                    if (field == 'username') username = controller.text.trim();
                    if (field == 'email') email = controller.text.trim();
                    if (field == 'phone') phone = controller.text.trim();
                  });
                }

                Navigator.pop(context); // Close popup
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }
}

editUsername() => showEditDialog('username', username ?? '');
editEmail() => showEditDialog('email', email ?? '');
editPhone() => showEditDialog('phone', phone ?? '');
editCurrency() => showEditDialog('baseCurrency', baseCurrency ?? '');


  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        leading: IconButton(onPressed: () {}, icon: Icon(Icons.menu, color: Colors.white)),
        backgroundColor: const Color(0xFF388E3C),
        title: Text("Profile", style: TextStyle(color: Colors.white)),
      ),
      body: isLoading
  ? Center(child: CircularProgressIndicator(color: Color(0xFF388E3C)))
  :  Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Color.fromARGB(255, 238, 240, 238),
                        child: Icon(
                          Icons.person,
                          size: 80,
                          color: Color(0xFF388E3C),
                        ),
                      ),
                      SizedBox(height: 30),

                      Column(
                  
                        children: [
                          Row(
                             mainAxisAlignment: MainAxisAlignment.center, 
                            children: [
                              Text(
                                "Username: $username",
                                style: TextStyle(fontSize: 18),
                              ),
                              SizedBox(width: 15),
                             IconButton(onPressed: editUsername,
                              icon: Icon(Icons.edit , color:  Color(0xFF388E3C),)) ,
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                             mainAxisAlignment: MainAxisAlignment.center, 
                            children: [
                              Text(
                                " Email: $email",
                                style: TextStyle(fontSize: 18),
                              ),
                              SizedBox(width: 15),
                             IconButton(onPressed: editEmail,
                              icon: Icon(Icons.edit, color:  Color(0xFF388E3C),)) ,
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                             mainAxisAlignment: MainAxisAlignment.center, 
                            children: [
                              Text(
                                "Phone: $phone",
                                style: TextStyle(fontSize: 18),
                              ),
                              SizedBox(width: 15),

                            IconButton(onPressed:editPhone,
                             icon: Icon(Icons.edit, color:  Color(0xFF388E3C),)) ,
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                             mainAxisAlignment: MainAxisAlignment.center, 
                            children: [
                              Text(
                                " Currency: $baseCurrency",
                                style: TextStyle(fontSize: 18),
                              ),
                              SizedBox(width: 15),

                            IconButton(onPressed: 
                               editCurrency
                             , icon: Icon(Icons.edit, color:  Color(0xFF388E3C),)) ,
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
