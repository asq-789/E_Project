import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? username, email, phone, country, baseCurrency;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        setState(() {
          username = userData?['username'];
          email = userData?['email'];
          phone = userData?['phone'];
          country = userData?['country'];
          baseCurrency = userData?['baseCurrency'];
          isLoading = false;
        });
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
        title: Text("Currensee"),
        backgroundColor: Color(0xFF388E3C),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF388E3C)))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Color.fromARGB(255, 238, 240, 238),
                      child: Icon(Icons.person, size: 80, color: Color(0xFF388E3C)),
                    ),
                    SizedBox(height: 30),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                         Text("Username: $username", style: TextStyle(fontSize: 18)),
                    SizedBox(height: 16),
                    Text(" Email: $email", style: TextStyle(fontSize: 18)),
                    SizedBox(height: 16),
                    Text("Phone: $phone", style: TextStyle(fontSize: 18)),
                    SizedBox(height: 16),
                    Text(" Country: $country", style: TextStyle(fontSize: 18)),
                       SizedBox(height: 16),
                    Text(" Currency: $baseCurrency", style: TextStyle(fontSize: 18)),
                     ],
                    )
                   
                  ],
                ),
              ),
            ),
    );
  }
}
