import 'package:currensee/screens/Charts.dart';
import 'package:currensee/screens/contactus.dart';
import 'package:currensee/screens/currency_list.dart';
import 'package:currensee/screens/feedback.dart';
import 'package:currensee/screens/home.dart';
import 'package:flutter/material.dart';


class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  const BottomNavBar({super.key, required this.currentIndex});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}



class _BottomNavBarState extends State<BottomNavBar> {


  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex; 
  }
     void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
     switch (_selectedIndex) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const Charts()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const CurrencyList()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactScreen()));
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const FeedbackScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF388E3C),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: "Convert"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Charts"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Currency List"),
          BottomNavigationBarItem(icon: Icon(Icons.contact_mail), label: "Contact Us"),
          BottomNavigationBarItem(icon: Icon(Icons.feedback), label: "Feedback"),
        ],
      );
  }
}