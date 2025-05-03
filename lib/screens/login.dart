import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool _obscurePassword = true;

  login() async {
       final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
  prefs.setBool("isLoggedIn",true);
  print(prefs.getBool("isLoggedIn"));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );

        Navigator.pushReplacementNamed(context, '/');
      } on FirebaseAuthException catch (e) {
        String errorMsg = e.code == 'user-not-found'
            ? 'No user found with this email.'
            : e.code == 'wrong-password'
                ? 'Incorrect password.'
                : 'Login failed. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("An error occurred")));
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  InputDecoration _inputDecoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF388E3C)),
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[600], fontSize: 15),
      suffixIcon: Icon(icon, color: Colors.grey, size: 18),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF388E3C)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF388E3C), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
   

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
  textDirection: TextDirection.ltr,
  verticalDirection: VerticalDirection.down,
          children: [
            const SizedBox(height: 20),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24), bottom: Radius.circular(24)),
             boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 12,
                  spreadRadius: 4,
                  offset: Offset(0, 6),
                ),
              ], ),
              padding: const EdgeInsets.all(24.0),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Welcome Back",
                        style: TextStyle(
                          fontSize: 28,
                          color: Color.fromARGB(255, 64, 160, 69),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "Hello there, sign in to continue",
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 40),
                 Container(
  decoration: BoxDecoration(
    color: const Color.fromARGB(255, 196, 233, 199),
    borderRadius: BorderRadius.circular(70),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.6),
        spreadRadius: 1,
        blurRadius: 8,
        offset: const Offset(0, 5),
      ),
    ],
  ),
  padding: const EdgeInsets.all(22),
  child: Icon(Icons.lock, color: Color.fromARGB(255, 64, 160, 69), size: 80),
),

                    const SizedBox(height: 40),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration('Email', 'Enter your email', Icons.email),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter your email';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Color.fromARGB(255, 64, 160, 69)),
                        hintText: "Enter your password",
                        hintStyle: TextStyle(color: Colors.grey[600], fontSize: 15),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                            size: 18,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color.fromARGB(255, 64, 160, 69)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color.fromARGB(255, 64, 160, 69), width: 1.5),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) return 'Minimum 6 characters required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),
                    isLoading
                        ? Center(child: CircularProgressIndicator(color: Color.fromARGB(255, 64, 160, 69)))
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(255, 64, 160, 69),
                                elevation: 5,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text("Login", style: TextStyle(fontSize: 16, color: Colors.white)),
                            ),
                          ),
                    const SizedBox(height: 30),
              Wrap(
  alignment: WrapAlignment.center,
  spacing: 5.0,
  children: [
    Text("Don't have an account? ", style: TextStyle(color: Colors.black)),
    GestureDetector(
      onTap: () => Navigator.pushNamed(context, "/signup"),
      child: Text(
        "Signup",
        style: TextStyle(color: Color.fromARGB(255, 64, 160, 69), fontWeight: FontWeight.bold),
      ),
    ),
  ],
),
  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
   }