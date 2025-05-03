import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currensee/components/bottom_navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:currensee/components/my_appbar.dart';

class LikedCurrrencies extends StatefulWidget {
  const LikedCurrrencies({super.key});

  @override
  State<LikedCurrrencies> createState() => _LikedCurrrenciesState();
}

class _LikedCurrrenciesState extends State<LikedCurrrencies> {
  bool notificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: CustomAppBar(
        notificationsEnabled: notificationsEnabled,
        title: "Liked Currencies",
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
 body: SingleChildScrollView(
   child: Padding(
     padding: const EdgeInsets.all(25),
     child: Column(
       children: [
        
         StreamBuilder<QuerySnapshot>(
           stream: FirebaseFirestore.instance
               .collection('liked_currencies')
               .doc(FirebaseAuth.instance.currentUser!.uid)
               .collection('currencies')
               .snapshots(),
           builder: (context, snapshot) {
             if (snapshot.connectionState == ConnectionState.waiting) {
               return const Center(child: CircularProgressIndicator());
             }
 
             if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
               return const Center(child: Text("No liked currencies"));
             }
 
             final docs = snapshot.data!.docs;
 
             return Column(
               children: docs.map((doc) {
                 final data = doc.data() as Map<String, dynamic>;
 
                 return Card(
                   margin: const EdgeInsets.only(bottom: 20),
                   elevation: 3,
                   shadowColor: Colors.green.shade100,
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(10),
                   ),
                   child: Padding(
                     padding: const EdgeInsets.all(18.0),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(
                                 data['name'],
                                 style: const TextStyle(
                                   fontSize: 19,
                                   letterSpacing: 2,
                                   fontWeight: FontWeight.bold,
                                 ),
                               ),
                               const SizedBox(height: 7),
                               Text(
                                 "1 ${data['symbol']} = ${data['value']} ${data['name']}",
                                 style: const TextStyle(
                                   fontSize: 14,
                                   fontWeight: FontWeight.bold,
                                   color: Color(0xFF388E3C),
                                 ),
                               ),
                               const SizedBox(height: 7),
                               Row(
                                 children: [
                                   Expanded(
                                     child: Text(
                                       "Last Updated: ${data['lastUpdated']}",
                                       style: TextStyle(
                                         fontSize: 10,
                                         color: Colors.grey[600],
                                       ),
                                     ),
                                   ),
                                   Expanded(
                                     child: Text(
                                       "Next Update: ${data['nextUpdate']}",
                                       style: TextStyle(
                                         fontSize: 10,
                                         color: Colors.grey[600],
                                       ),
                                       textAlign: TextAlign.end,
                                     ),
                                   ),
                                 ],
                               ),
                             ],
                           ),
                         ),
                         IconButton(
                           icon: const Icon(
                             Icons.favorite,
                             color: Color(0xFF388E3C),
                           ),
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
                 );
               }).toList(),
             );
           },
         ),
       ],
     ),
   ),
 ),
bottomNavigationBar: BottomNavBar(currentIndex: 0),
    );
  }
}