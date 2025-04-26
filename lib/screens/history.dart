import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currensee/components/bottom_navbar.dart';
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
         title: "History",
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
  margin: const EdgeInsets.only(bottom: 16),
  elevation: 4,
  shadowColor: Colors.grey.withOpacity(0.2),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amount: $amount',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '$fromCurrency → $toCurrency',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF388E3C),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text('Rate: ',
                          style: TextStyle(color: Colors.black54)),
                      SizedBox(width: 4),
                      Text('$rate', style: TextStyle(color: Colors.black87)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text('Total: ',
                          style: TextStyle(color: Colors.black54)),
                      SizedBox(width: 4),
                      Text('$total', style: TextStyle(color: Colors.black87)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    deleteHistoryItem(conversion.id);
                  },
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ),
);

},
);
           }),
      ),
bottomNavigationBar: BottomNavBar(currentIndex: 0), // Home
    );
  }
}