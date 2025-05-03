import 'dart:convert';
import 'package:currensee/components/bottom_navbar.dart';
import 'package:currensee/components/my_appbar.dart';
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
    bool notificationsEnabled = false;
bool showEditIcons = false;


 Map<String, dynamic> currencyMap = {};
List<String> currencyList = [];

@override
void initState() {
  super.initState();
  fetchUserData();
  getCurrencyData(); 
}

Future<void> getCurrencyData() async {
  var url = Uri.parse('https://v6.exchangerate-api.com/v6/2f386b0f1eb2f3e88a4ec4a0/latest/USD');
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
        title: Text('Edit Currency',style: TextStyle(color:Color(0xFF388E3C),fontWeight:FontWeight.w500 ),),
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
  labelStyle: TextStyle(color: Color(0xFF388E3C)), 
  border: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFF388E3C)), 
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFF388E3C), width: 2), 
  ),
),

        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',style: TextStyle(color:Color(0xFF388E3C) ),),
          ),
          ElevatedButton(
             style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF388E3C), 
    foregroundColor: Colors.white, 
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
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

              Navigator.pop(context); 
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
          title: Text('Edit $field',style: TextStyle(color:Color(0xFF388E3C),fontWeight:FontWeight.w500 ),),
          content: TextField(
            controller: controller,
           decoration: InputDecoration(
  labelText: "New $field",
  labelStyle: TextStyle(color: Color(0xFF388E3C)),
  border: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFF388E3C)), 
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFF388E3C), width: 2), 
  ),
),

          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',style: TextStyle(color:Color(0xFF388E3C) ),),
            ),
            ElevatedButton(
               style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF388E3C), 
    foregroundColor: Colors.white, 
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
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
          backgroundColor: Colors.white,

    appBar: CustomAppBar(
      notificationsEnabled: notificationsEnabled,
       title: "Profile",
      onToggleNotifications: () {
        setState(() {
          notificationsEnabled = !notificationsEnabled;
        });
      },
    ),
    drawer: CustomDrawer(
      // notificationsEnabled: notificationsEnabled,
      // onNotificationsChanged: (bool value) {
      //   setState(() {
      //     notificationsEnabled = value;
      //   });
      // },
    ),
    body: isLoading
        ? Center(child: CircularProgressIndicator(color: Color(0xFF388E3C)))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                SizedBox(height: 15,),
           Container(
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(
       color: Colors.grey.withOpacity(0.6),
        spreadRadius: 1,
        blurRadius: 8,
        offset: const Offset(0, 5), 
      ),
    ],
  ),
  child: CircleAvatar(
    radius: 60,
    backgroundColor: const Color.fromARGB(255, 196, 233, 199),
    child: Icon(
      Icons.person,
      size: 80,
      color: Color(0xFF388E3C),
    ),
  ),
),

                SizedBox(height: 25),
                           Text(
  username ?? 'User',
  style: TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.italic,
    color: Color(0xFF388E3C),
    shadows: [
      Shadow(
        offset: Offset(2, 2),
        blurRadius: 3,
        color: const Color.fromARGB(66, 114, 114, 113),
      ),
    ],
  ),
  textAlign: TextAlign.center,
),
               
                SizedBox(height: 30),

                // User Detail Cards
                buildProfileCard("Username", username ?? '', editUsername),
                buildProfileCard("Email", email ?? '', editEmail),
                buildProfileCard("Phone", phone ?? '', editPhone),
                buildProfileCard("Base Currency", baseCurrency ?? '', editCurrency),
              ],
            ),
          ),
bottomNavigationBar: BottomNavBar(currentIndex: 0), // Home
  );
}
}
Widget buildProfileCard(String label, String value, VoidCallback onEdit) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 4,
    margin: EdgeInsets.symmetric(vertical: 12),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "$label :  ",
                  
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF388E3C), 
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: Icon(Icons.edit, color: Color(0xFF388E3C)),
          ),
        ],
      ),
    ),
  );
}