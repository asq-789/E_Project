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

  TextEditingController fullnameController =TextEditingController();
    TextEditingController emailController =TextEditingController();
  TextEditingController subjectController =TextEditingController();
  TextEditingController messageController =TextEditingController();

void _launchURL(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Could not launch $url")));
  }
}

sendMessage()async{
  if (_formKey.currentState!.validate()) {
String fullname = fullnameController.text;
String email = emailController.text;
String subject= subjectController.text;
String message = messageController.text;
try{
  await FirebaseFirestore.instance.collection('Contact').add({
    'fullname':fullname,
    'email': email,
    'subject': subject,
    'message':message,
  });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Message send Successfully")));
      fullnameController.clear();
      emailController.clear();
subjectController.clear();
messageController.clear();}
  catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));

  }

}
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        notificationsEnabled: notificationsEnabled,
        onNotificationsChanged: (bool value) {
          setState(() {
            notificationsEnabled = value;
          });
        },
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
             
              children: [ SizedBox(height: 20,),
            Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    Column(
      children: [
        InkWell(
          onTap: () => _launchURL('tel:+921234567890'),
          borderRadius: BorderRadius.circular(30),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Color(0xFF388E3C),
              child: Icon(Icons.phone, color: Colors.white),
            ),
          ),
        ),
        SizedBox(height: 6),
        Text("Phone", style: TextStyle(color: Color(0xFF388E3C))),
        Text("+92 123 4567890", style: TextStyle(fontSize: 12)),
      ],
    ),
    Column(
      children: [
        InkWell(
          onTap: () => _launchURL('mailto:contact@email.com'),
          borderRadius: BorderRadius.circular(30),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Color(0xFF388E3C),
              child: Icon(Icons.email, color: Colors.white),
            ),
          ),
        ),
        SizedBox(height: 6),
        Text("Email", style: TextStyle(color: Color(0xFF388E3C))),
        Text("contact@email.com", style: TextStyle(fontSize: 12)),
      ],
    ),
    Column(
      children: [
        InkWell(
          onTap: () => _launchURL('https://www.currensee.app'),
          borderRadius: BorderRadius.circular(30),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Color(0xFF388E3C),
              child: Icon(Icons.language, color: Colors.white),
            ),
          ),
        ),
        SizedBox(height: 6),
        Text("Website", style: TextStyle(color: Color(0xFF388E3C))),
        Text("currensee.app", style: TextStyle(fontSize: 12)),
      ],
    ),
  ],
),

                SizedBox(height: 20,),
                TextFormField(
                controller: fullnameController,
                decoration: InputDecoration(
                   label:Text("Fullname"),
                hintText: 'Enter your Fullname',
                border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person_outlined,color: Color(0xFF388E3C),),
            
                ),
                validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your fullname';
                }
                return null;
              },
                ),
                SizedBox(height: 20,),
                     TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                   label:Text("Email"),
                hintText: 'Enter your Email',
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
                SizedBox(height: 20,),
                     TextFormField(
                controller: subjectController,
                decoration: InputDecoration(
                   label:Text("Subject"),
                hintText: 'Enter your Subject',
                border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.subject_outlined,color: Color(0xFF388E3C)),
            
                ),
                 validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the subject';
                }
                return null;
              },
                ),
                SizedBox(height: 20,),
                      TextFormField(
                controller: messageController,
                maxLines: 5,
                decoration: InputDecoration(
                   label:Text("Message"),
                hintText: 'Enter your Message',
                border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.message_outlined,color: Color(0xFF388E3C)),
            
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
                onPressed: sendMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF388E3C),
                ),
                child: Center(child: Text("Send", style: TextStyle(fontSize: 16, color: Colors.white))),
              ),  ],
            ),
          ),
        ),
      ),
        bottomNavigationBar: BottomNavBar(),
      );
  }
}