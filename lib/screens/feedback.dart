import 'package:currensee/components/bottom_navbar.dart';
import 'package:currensee/components/my_appbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  bool notificationsEnabled = false;
  final _formKey = GlobalKey<FormState>();

  TextEditingController fullnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController feedbackController = TextEditingController();

  sendFeedback() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('feedbacks').add({
          'fullname': fullnameController.text,
          'email': emailController.text,
          'feedback': feedbackController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Feedback sent successfully")),
        );
        fullnameController.clear();
        emailController.clear();
        feedbackController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

 InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Color(0xFF388E3C)),
      prefixIcon: Icon(icon, color: Color(0xFF388E3C)),
      filled: true,
      fillColor: Color(0xFFF9F9F9),
      contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFF388E3C)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFF388E3C), width: 1.5),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        notificationsEnabled: notificationsEnabled,
        title:"Feedback",
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               SizedBox(height: 15),
             Text(
  "Give Us Your Feedback",
  style: TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: Color(0xFF388E3C),
  ),
  textAlign: TextAlign.center,
),
SizedBox(height: 4),
Text(
  "Your feedback is valuable to us. Help us improve!",
  style: TextStyle(
    fontSize: 15,
     fontStyle: FontStyle.italic, 
    color: Colors.black54,
  ),
  textAlign: TextAlign.center,
),


               SizedBox(height: 30),
              TextFormField(
                controller: fullnameController,
                decoration: _inputDecoration('Full Name', Icons.person_outline),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your fullname' : null,
              ),
               SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                decoration: _inputDecoration('Email Address', Icons.email_outlined),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your email';
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
                decoration: _inputDecoration('Your Feedback', Icons.feedback_outlined),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your message' : null,
              ),
               SizedBox(height: 30),
         Container(
  decoration: BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        spreadRadius: 1,
        blurRadius: 8,
        offset: Offset(0, 4), 
      ),
    ],
    borderRadius: BorderRadius.circular(12),
  ),
  child: SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: sendFeedback,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF388E3C),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0, 
      ),
      child: const Text(
        "Send",
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    ),
  ),
),

              const SizedBox(height: 40),

Column(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    Text(
      "Users Feedbacks",
      style: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Color(0xFF388E3C),
      ),
      textAlign: TextAlign.center,
    ),
    const SizedBox(height: 6),
    Text(
      "See what others are saying about our app",
      style: TextStyle(
        fontSize: 15,
        color: Colors.black54,
        fontStyle: FontStyle.italic,
      ),
      textAlign: TextAlign.center,
    ),
  ],
),
const SizedBox(height: 20),


StreamBuilder(
  stream: FirebaseFirestore.instance
      .collection('feedbacks')
      .orderBy('timestamp', descending: true)
      .snapshots(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF388E3C)),
        ),
      );
    }
    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(child: Text("No feedbacks submitted yet.")),
      );
    }
return Column(
  children: snapshot.data!.docs.map((doc) {
    var data = doc.data() as Map;
    Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
    DateTime date = timestamp.toDate();
    String formattedDate = "${date.day}/${date.month}/${date.year}";
    String name = data['fullname'] ?? '';
    String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    int stars = data['stars'] ?? 5; 

return Container(
  width: double.infinity,
  margin: const EdgeInsets.symmetric(vertical: 10),
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: const Color.fromARGB(255, 245, 243, 243),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: const Color.fromARGB(255, 223, 222, 222)),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 8,
        offset: Offset(2, 4),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFF388E3C),
            child: Text(
              initial,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF388E3C),
                ),
              ),
              SizedBox(height: 2),
              Text(
                "Email: ${data['email'] ?? ''}",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
      SizedBox(height: 8),
      Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '“ ${data['feedback'] ?? ''} ”',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Date: $formattedDate",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      Icons.star,
                      color: index < stars
                          ? Color(0xFF388E3C)
                          : Colors.grey.shade300,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
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
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
