import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:currensee/components/my_appbar.dart';
class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
    bool notificationsEnabled = false;

Future<void> deleteHistoryItem(String documentId) async {
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('history')
        .doc(documentId)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('History item deleted')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to delete item')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar:  CustomAppBar(
        notificationsEnabled: notificationsEnabled,
        onToggleNotifications: () {
          setState(() {
            notificationsEnabled = !notificationsEnabled;
          });
        },
      ),
      drawer: CustomDrawer(
        notificationsEnabled: notificationsEnabled,
        onNotificationsChanged: (bool value) {
          setState(() {
            notificationsEnabled = value;
          });
        },
      ),
     
      body: Padding(
        padding: const EdgeInsets.all(16),
        
        child: StreamBuilder<QuerySnapshot>(
          
          stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).collection('history') .orderBy('timestamp', descending: true)
        .snapshots(),
           builder: (context,snapshot) {
            if(!snapshot.hasData){
              return Center(child: CircularProgressIndicator(color: Color(0xFF388E3C)),);
            }
            var data = snapshot.data!.docs;
        
            return ListView.builder(
              itemCount: data.length,
itemBuilder: (context, index) {
  var conversion = data[index];
  var amount = conversion['amount'];
  var fromCurrency = conversion['from_currency'];
  var toCurrency = conversion['to_currency'];
  var rate = conversion['rate'];
  var total = conversion['total'];
  var timestamp = conversion['timestamp'].toDate();
  String formattedDate = DateFormat.yMMMd().add_jm().format(timestamp);

  return Card(
    margin: const EdgeInsets.only(bottom: 20),
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Amount: $amount',
                style: TextStyle(color: Colors.grey[700]),
              ),
              SizedBox(height: 6),
              Text(
                '$fromCurrency → $toCurrency',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 6),
              Text(
                'Rate: $rate',
                style: TextStyle(color: Colors.grey[700]),
              ),
              Text(
                'Total: $total',
                style: TextStyle(color: Colors.grey[700]),
              ),
              SizedBox(height: 6),
              Text(
                formattedDate,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        
          Positioned(
            top: 2,
            right: 2,
            child: IconButton(
              onPressed: () {
                deleteHistoryItem(conversion.id);
              },
              icon: Icon(
                Icons.close, 
                color: Colors.grey[700],size: 18,
              ),
            ),
          ),
        ],
      ),
    ),
  );
},
);
           }),
      ),
    );
  }
}