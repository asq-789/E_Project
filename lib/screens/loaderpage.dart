import 'package:flutter/material.dart';

class Currensee extends StatefulWidget {
  const Currensee({super.key});

  @override
  State<Currensee> createState() => _CurrenseeState();
}

class _CurrenseeState extends State<Currensee> with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> fadeInAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        setState(() {});
      });

    fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeIn),
    );

    controller.forward(); 

   
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(width * 0.1), 
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Stack(
                alignment: Alignment.center,
                children: [
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
                  Image.asset(
                    'public/assets/images/bg.png',
                    height: 100,
                  ),
                ],
              ),
              const SizedBox(height: 50),
              FadeTransition(
                opacity: fadeInAnimation,
                child: const Text(
  'CurrenSee',
  style: TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w900, 
    fontStyle: FontStyle.italic,
    fontFamily: 'Times New Roman',
    color: Color(0xFF388E3C),
    shadows: [
      Shadow(
        offset: Offset(2.0, 2.0),
        blurRadius: 5.0,
        color: Color.fromRGBO(0, 0, 0, 0.3), 
      ),
    ],
  ),
),

              ),
            ],
          ),
        ),
      ),
    );
  }
}
