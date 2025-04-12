import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController feedbackController = TextEditingController();

  sendFeedback() async {
    String name = nameController.text;
    String email = emailController.text;
    String feedback = feedbackController.text;
    if (name.isEmpty || email.isEmpty || feedback.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all fields")));
      return;
    }
    try {
      await FirebaseFirestore.instance.collection('feedbacks').add({
        'name': name,
        'email': email,
        'feedback': feedback,
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Feedback sent successfully")));
      nameController.clear();
      emailController.clear();
      feedbackController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () {}, icon: Icon(Icons.menu, color: Colors.white)),
        backgroundColor: const Color(0xFF388E3C),
        title: Text("Feedback", style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(height: 20),
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              label: Text('Name'),
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outlined),
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: emailController,
            decoration: InputDecoration(
              label: Text('Email'),
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: feedbackController,
            maxLines: 5,
            decoration: InputDecoration(
              label: Text('Feedback'),
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.message_outlined),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: sendFeedback,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF388E3C),
            ),
            child: Center(child: Text("Send", style: TextStyle(fontSize: 16, color: Colors.white))),
          ),
          SizedBox(height: 40),
          Text("Users Feedbacks", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          SizedBox(
            height: 400,
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('feedbacks').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text("No feedbacks submitted yet.");
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var data = snapshot.data!.docs[index].data() as Map;
                    Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
                    DateTime date = timestamp.toDate();
                    String formattedDate = "${date.day}/${date.month}/${date.year}";
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text("Name: ${data['name'] ?? ''}", style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Email: ${data['email'] ?? ''}", style: TextStyle(fontSize: 12, color: Colors.black87)),
                            SizedBox(height: 4),
                            Text(data['feedback'] ?? ''),
                            SizedBox(height: 4),
                            Text("Date: $formattedDate", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
