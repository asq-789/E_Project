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

login()async{
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
  }else{
     errorMsg = 'Login failed. Please try again.';
  }
 ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );

} catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("An error occurred")));
      }
finally {
        setState(() => isLoading = false); 
      }

}}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
                           Text("Login", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
    SizedBox(height: 40),
              TextFormField(
                controller: emailController,
                 keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  label: Text("Email"),
                  hintText: "Enter Your Email",
                  border: OutlineInputBorder(),
                
                 
                ),
                 
                   validator: (value) {
                  if (value == null || value.isEmpty) return 'Email is required';
                  if (!value.contains('@')) return 'Enter a valid email';
                  return null;
                }, 
              ),
              SizedBox(height: 40,),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  label: Text("Password"),
                  hintText: "Enter Your Password",
                  border: OutlineInputBorder(),
                ),
                 validator: (value) {
                  if (value == null || value.isEmpty) return 'Password is required';
                  if (value.length < 6) return 'Minimum 6 characters required';
                  return null;
                },
               
              ),
              SizedBox(height: 40,),

               isLoading
                  ? const CircularProgressIndicator()
                  :
SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: login,
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF388E3C),
  
    ), 
    child: Text("Login", style: TextStyle(fontSize: 16, color: Colors.white)),
  ),
),

SizedBox(height: 20,),
              GestureDetector(onTap: (){
            Navigator.pushNamed(context, "/signup");
          },
          child: Text("Don't have an account?... Sign up", style: TextStyle(color: Colors.blue)),),
             
              
            ],
          ),
        ),
      ),
    );

  }
}