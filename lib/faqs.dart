import 'package:currensee/components/bottom_navbar.dart';
import 'package:currensee/components/my_appbar.dart'; // Importing custom appbar
import 'package:flutter/material.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  bool notificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        notificationsEnabled: notificationsEnabled,
        title: "FAQs",
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
        child: Column(
         
          children: [ SizedBox(height: 25,),
            FaqItem(
              question: "What is Currensee ?",
              answer:
                  "Currensee is a currency conversion app that allows you to convert currencies in real-time using live exchange rates.",
            ),
            FaqItem(
              question: "How do I convert currencies ?",
              answer:
                  "To convert currencies, simply input the amount in the 'Amount' field, select the 'From' and 'To' currencies, and press 'Convert'.",
            ),
            FaqItem(
              question: "What currencies are supported ?",
              answer:
                  "Currensee supports a wide range of currencies from across the globe. You can select from the list of available currencies for conversion.",
            ),
            FaqItem(
              question: "How accurate are the exchange rates ?",
              answer:
                  "The exchange rates are updated in real-time from a reliable API, providing accurate and up-to-date conversion rates.",
            ),
            FaqItem(
              question: "Can I save my conversion history ?",
              answer:
                  "Currently, saving conversion history is not a feature in Currensee. But we plan to add this functionality in the future.",
            ),
            FaqItem(
              question: "How do I change the currencies ?",
              answer:
                  "To change currencies, tap the swap icon between the 'From' and 'To' fields. This will swap the selected currencies.",
            ),
            FaqItem(
              question: "Can I get notifications for rate changes ?",
              answer:
                  "Yes, you can enable notifications in the settings. This will notify you about significant changes in the selected exchange rate.",
            ),
            FaqItem(
              question: "How do I contact customer support ?",
              answer:
                  "To contact support, go to the 'Help Center' section in the app. You can either read FAQs or contact support directly.",
            ),
            FaqItem(
              question: "Is this app free to use ?",
              answer:
                  "Yes, Currensee is completely free to use for currency conversions. There are no hidden fees or charges.",
            ),
            FaqItem(
              question: "How do I log out of the app ?",
              answer:
                  "To log out, go to the settings menu in the app and select 'Logout'. You will be logged out of your current session.",
            ),
            FaqItem(
              question: "How do I update the app ?",
              answer:
                  "Updates for Currensee are available through the App Store (iOS) or Google Play Store (Android). Please make sure your device is connected to the internet to get the latest version.",
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 0),
    );
  }
}
class FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const FaqItem({
    required this.question,
    required this.answer,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4, 
      shadowColor: Color(0xFF388E3C).withOpacity(0.5), 
      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
      shape: RoundedRectangleBorder( 
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          iconTheme: IconThemeData(color: Color(0xFF388E3C)),
        ),
        child: ExpansionTile(
          iconColor: Color(0xFF388E3C),
          collapsedIconColor: Color(0xFF388E3C),
          title: Text(
            question,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                answer,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF388E3C),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
