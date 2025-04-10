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
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Total loading time
    )..addListener(() {
        setState(() {});
      });

    controller.forward(); // Start animation
    super.initState();
  }

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
            // Display Logo in the center
            Image.asset(
              'public/assets/images/logogreen.png', 
              height: 150, 
            ),
            const SizedBox(height: 50),
            
          
            const Text(
              'Welcome to CurrenSee Converter',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Fredoka', // change this
                color: Color(0xFF388E3C), 
              ),
            ),
            const SizedBox(height: 30),

            // Loading bar
            LinearProgressIndicator(
              borderRadius: BorderRadius.circular(20),
              value: controller.value,
              minHeight: 12,
              backgroundColor: Colors.grey[300],
              color: const Color(0xFF388E3C), 
            ),
            const SizedBox(height: 30),

            // Show Login and Signup buttons 
            if (controller.value == 1.0)
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF388E3C),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), 
                      ),
                      foregroundColor: Colors.white, 
                      textStyle: const TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold, 
                        fontFamily: 'Fredoka', 
                      ),
                    ),
                    child: const Text("Login"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF388E3C), 
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), 
                      ),
                      foregroundColor: Colors.white, 
                      textStyle: const TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold, 
                        fontFamily: 'Fredoka',
                      ),
                    ),
                    child: const Text("Signup"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}