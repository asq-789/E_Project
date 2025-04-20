import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );

        Navigator.pushReplacementNamed(context, '/home');
      } on FirebaseAuthException catch (e) {
        String errorMsg;
        if (e.code == 'user-not-found') {
          errorMsg = 'No user found with this email.';
        } else if (e.code == 'wrong-password') {
          errorMsg = 'Incorrect password.';
        } else {
          errorMsg = 'Login failed. Please try again.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("An error occurred")));
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Welcome Back",
                  style: TextStyle(fontSize: 28, color: Color(0xFF388E3C), fontWeight: FontWeight.bold),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Hello there, sign in to continue",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
              SizedBox(height: 40),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  label: Text("Email", style: TextStyle(color: Color(0xFF388E3C))),
                  hintText: "Enter your email",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey)),
                  suffixIcon: Icon(Icons.email, color: Colors.grey, size: 18),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your email';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              TextFormField(
                controller: passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  label: Text("Password", style: TextStyle(color: Color(0xFF388E3C))),
                  hintText: "Enter password",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey)),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.length < 6) return 'Minimum 6 characters required';
                  return null;
                },
              ),
              SizedBox(height: 40),
              isLoading
                  ? Center(child: CircularProgressIndicator(color: Color(0xFF388E3C)))
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF388E3C),
                          elevation: 5,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text("Login", style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
         
              SizedBox(height: 20),

             Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Text("Don't have an account? ", style: TextStyle(color: Colors.black)),
      SizedBox(width: 5,),
    GestureDetector(
      onTap: () => Navigator.pushNamed(context, "/signup"),
      child: Text("Signup", style: TextStyle(color: Color(0xFF388E3C), fontWeight: FontWeight.bold)),
    ),
  ],
),
            ],
          ),
        ),
      ),
    );
  }
}
