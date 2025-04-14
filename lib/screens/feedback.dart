import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {

final _formKey = GlobalKey<FormState>();


  TextEditingController fullnameController= TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController feedbackController = TextEditingController();

  sendFeedback() async {
      if (_formKey.currentState!.validate()) {

    String fullname = fullnameController.text;
    String email = emailController.text;
    String feedback = feedbackController.text;
  

    try {
      await FirebaseFirestore.instance.collection('feedbacks').add({
        'fullname': fullname,
        'email': email,
        'feedback': feedback,
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Feedback sent successfully")));
      fullnameController.clear();
      emailController.clear();
      feedbackController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SizedBox(height: 20),
            TextFormField(
              controller: fullnameController,
              decoration: InputDecoration(
                label: Text('Fullname'),
                hintText: 'Enter Your Fullname',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outlined,color: Color(0xFF388E3C)),
              ),
               validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your fullname';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                label: Text('Email'),
                hintText: 'Enter Your Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined,color: Color(0xFF388E3C)),
              ),
               validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
               
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: feedbackController,
              maxLines: 5,
              decoration: InputDecoration(
                label: Text('Feedback'),
                hintText: 'Write Feedback',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.feedback_outlined,color: Color(0xFF388E3C)),
              ),
                validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your message';
                }
                return null;
              },
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: sendFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF388E3C),
              ),
              child: Center(child: Text("Send", style: TextStyle(fontSize: 16, color: Colors.white))),
            ),
              SizedBox(height: 30),
            Divider(thickness: 1, color: Colors.grey.shade400),
        SizedBox(height: 30),
        
          
        Center(
          child: Text(
            "Users Feedbacks",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: const Color(0xFF388E3C)),
          ),
        ),
            SizedBox(height: 20),
            SizedBox(
              height: 400,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('feedbacks').orderBy('timestamp', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: Color(0xFF388E3C)));
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
                          title: Text("${data['fullname'] ?? ''}", style: TextStyle(fontWeight: FontWeight.bold)),
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
      ),
    );
  }
}
