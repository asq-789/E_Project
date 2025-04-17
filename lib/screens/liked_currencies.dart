import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:currensee/screens/currency_list.dart';

class LikedCurrrencies extends StatefulWidget {
  const LikedCurrrencies({super.key});

  @override
  State<LikedCurrrencies> createState() => _LikedCurrrenciesState();
}

class _LikedCurrrenciesState extends State<LikedCurrrencies> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){}, icon: Icon(Icons.menu),color: Colors.white,),
         backgroundColor: const Color(0xFF388E3C), 
        title: Text('Likes',style: TextStyle(color: Colors.white),),
      ),
     body: Padding(
       padding: const EdgeInsets.all(20),
       child: StreamBuilder<QuerySnapshot>(
         stream: FirebaseFirestore.instance
        .collection('liked_currencies')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('currencies')
        .snapshots(),
         builder: (context, snapshot) {
           if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
           }
       
           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Center(child: Text("No liked currencies"));
           }
       
           final docs = snapshot.data!.docs;
       
           return ListView.builder(
        itemCount: docs.length,
        itemBuilder: (context, index) {
          final data = docs[index].data() as Map<String, dynamic>;
       
          return Padding(
  padding: const EdgeInsets.all(10.0),
  child: Card(
    elevation: 3,
    shadowColor: Colors.green.shade100,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['name'],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 7),
              Text(
               "1 ${data['symbol']} = ${data['value']} ${data['name']}",
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Text(
                    "Last Updated: ${data['lastUpdated']}",
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                  SizedBox(width: 40),
                  Text(
                    "Next Update: ${data['nextUpdate']}",
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.favorite, color: Colors.red),
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await FirebaseFirestore.instance
                    .collection('liked_currencies')
                    .doc(user.uid)
                    .collection('currencies')
                    .doc(data['name'])
                    .delete();
              }
            },
          ),
        ],
      ),
    ),
  ),
);

        },
           );
         },
       ),
     )
  );
  }
}