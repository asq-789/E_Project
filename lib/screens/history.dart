import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        leading: IconButton(onPressed: () {}, icon: Icon(Icons.menu, color: Colors.white)),
        backgroundColor: const Color(0xFF388E3C),
        title: Text("Conversions History", style: TextStyle(color: Colors.white)),
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
              itemBuilder: (context, index){
                var conversion = data[index];
                var fromCurrency = conversion['from_currency'];
                var toCurrency = conversion['to_currency'];
                 var rate = conversion['rate'];
                var total = conversion['total'];
                var timestamp = conversion['timestamp'].toDate();
                
         String formattedDate = DateFormat.yMMMd().add_jm().format(timestamp);

                return Card(
                    margin: const EdgeInsets.only(bottom: 20),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child:  Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                  ],),
                ),
                 
                );
              });
           }),
      ),
    );
  }
}