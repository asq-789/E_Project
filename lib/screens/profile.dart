import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

 String? username, email, phone, country;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        setState(() {
          // name = userData?['name'];
          email = userData?['email'];
          phone = userData?['phone'];
          country = userData?['country'];
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
        leading: IconButton(onPressed: (){}, icon: Icon(Icons.menu)),
        title: Text("Currensee"),
      ),
body:isLoading? 
Center(child: CircularProgressIndicator()):Padding(
  padding: const EdgeInsets.all(16),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("👤 Name: $username", style: TextStyle(fontSize: 18)),
                    SizedBox(height: 16),
                    Text("📧 Email: $email", style: TextStyle(fontSize: 18)),
                    SizedBox(height: 16),
                    Text("📱 Phone: $phone", style: TextStyle(fontSize: 18)),
                    SizedBox(height: 16),
                    Text("🌍 Currency: $country", style: TextStyle(fontSize: 18)),
                  ],
  ),
),
    );
  }
}