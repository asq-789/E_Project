import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Currensee extends StatefulWidget {
  const Currensee({super.key});

  @override
  State<Currensee> createState() => _CurrenseeState();
}

class _CurrenseeState extends State<Currensee> with TickerProviderStateMixin {
  late AnimationController controller;

@override

void initState() {
  super.initState();

  controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..addListener(() {
      setState(() {});
    });

  controller.forward(); 

  Future.delayed(const Duration(seconds: 3), () {
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  });
}

  // @override
  // void initState() {
  //   controller = AnimationController(
  //     vsync: this,
  //     duration: const Duration(seconds: 2), // Total loading time
  //   )..addListener(() {
  //       setState(() {});
  //     });

  //   controller.forward(); // Start animation

  //   // Navigate to login page after the loading is complete
  //   Future.delayed(const Duration(seconds: 2), () {
  //     if (controller.isCompleted) {
  //       Navigator.pushReplacementNamed(context, '/login');
  //     }
  //   });

  //   super.initState();
  // }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9), 
      body: Padding(
        padding: const EdgeInsets.all(60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Stack to display logo with circular loader
            Stack(
              alignment: Alignment.center,
              children: [
                // Circular Progress Indicator
                SizedBox(
                  height: 150,
                  width: 150,
                  child: CircularProgressIndicator(
                    value: controller.value,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[300],
                    color: const Color(0xFF388E3C),
                  ),
                ),
                // Logo in the center
                Image.asset(
                  'public/assets/images/logogreen.png',
                  height: 100,
                ),
              ],
            ),
            const SizedBox(height: 50),

            // Welcome text
            const Text(
              'Welcome to CurrenSee Converter',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Fredoka', 
                color: Color(0xFF388E3C), 
              ),
            ),
          ],
        ),
      ),
    );
  }
}
