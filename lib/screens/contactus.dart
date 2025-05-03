import 'package:currensee/components/bottom_navbar.dart';
import 'package:currensee/components/my_appbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  bool notificationsEnabled = false;

  final _formKey = GlobalKey<FormState>();
  TextEditingController fullnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  TextEditingController messageController = TextEditingController();

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Could not launch $url")));
    }
  }

  sendMessage() async {
    if (_formKey.currentState!.validate()) {
      String fullname = fullnameController.text;
      String email = emailController.text;
      String subject = subjectController.text;
      String message = messageController.text;
      try {
        await FirebaseFirestore.instance.collection('Contact').add({
          'fullname': fullname,
          'email': email,
          'subject': subject,
          'message': message,
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Message sent successfully")));
        fullnameController.clear();
        emailController.clear();
        subjectController.clear();
        messageController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
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
        title: "Contact",
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
        padding: EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 15),
               Text(
  "Contact Us",
  style: TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.italic,
    color: Color(0xFF388E3C),
    shadows: [
      Shadow(
        offset: Offset(2, 2),
        blurRadius: 3,
        color: const Color.fromARGB(66, 114, 114, 113),
      ),
    ],
  ),
  textAlign: TextAlign.center,
),

              SizedBox(height: 4),
              Text(
                "We’d love to hear from you. Reach out any time!",
                style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
         Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    Expanded(
      child: Column(
        children: [
          InkWell(
            onTap: () => _launchURL('tel:+921234567890'),
            borderRadius: BorderRadius.circular(30),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Color(0xFF388E3C),
                  child: Icon(Icons.phone, color: Colors.white),
                ),
              ),
            ),
          ),
          SizedBox(height: 6),
          Text("Phone", style: TextStyle(color: Color(0xFF388E3C))),
          Text("+92 123 4567890", style: TextStyle(fontSize: 12)),
        ],
      ),
    ),
    Expanded(
      child: Column(
        children: [
          InkWell(
            onTap: () => _launchURL('mailto:contact@email.com'),
            borderRadius: BorderRadius.circular(30),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Color(0xFF388E3C),
                  child: Icon(Icons.email, color: Colors.white),
                ),
              ),
            ),
          ),
          SizedBox(height: 6),
          Text("Email", style: TextStyle(color: Color(0xFF388E3C))),
          Text("contact@email.com", style: TextStyle(fontSize: 12)),
        ],
      ),
    ),
    Expanded(
      child: Column(
        children: [
          InkWell(
            onTap: () => _launchURL('https://www.currensee.app'),
            borderRadius: BorderRadius.circular(30),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Color(0xFF388E3C),
                  child: Icon(Icons.language, color: Colors.white),
                ),
              ),
            ),
          ),
          SizedBox(height: 6),
          Text("Website", style: TextStyle(color: Color(0xFF388E3C))),
          Text("currensee.app", style: TextStyle(fontSize: 12)),
        ],
      ),
    ),
  ],
),
SizedBox(height: 30),

              TextFormField(
                controller: fullnameController,
                decoration: _inputDecoration("Full Name", Icons.person_outline),
                validator: (value) => value!.isEmpty ? 'Please enter Full Name' : null,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: emailController,
                decoration: _inputDecoration("Email Address", Icons.email_outlined),
                validator: (value) => value!.isEmpty ? 'Please enter Email Address' : null,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: subjectController,
                decoration: _inputDecoration("Subject", Icons.subject_outlined),
                validator: (value) => value!.isEmpty ? 'Please enter Subject' : null,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: messageController,
                maxLines: 5,
                decoration: _inputDecoration("Your Message", Icons.message_outlined),
                validator: (value) => value!.isEmpty ? 'Please enter Your Message' : null,
              ),

              const SizedBox(height: 30),
           Container(
  decoration: BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: const Color.fromARGB(255, 56, 56, 56).withOpacity(0.2),
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
      onPressed: sendMessage,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF388E3C),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(90),
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

            ],
          ),
        ),
      ),
bottomNavigationBar: BottomNavBar(currentIndex: 3), 
    );
  }
}