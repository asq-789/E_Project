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

login()async{
   if (_formKey.currentState!.validate()) {
  try {
  final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: emailController.text.trim(),
    password: passwordController.text.trim(),
  );
  Navigator.pushReplacementNamed(context, '/home');
} on FirebaseAuthException catch (e) {
  if (e.code == 'user-not-found') {
    print('No user found for that email.');
    ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("No user found for that email.")));
  } else if (e.code == 'wrong-password') {
    print('Wrong password provided for that user.');
     ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Wrong password provided.")));
  }
} catch (e) {
  print(e.toString());
   ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred")),
        );
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
              Text("Login",style: TextStyle(fontSize: 32,fontWeight: FontWeight.bold),),
              SizedBox(height: 40,),
              TextFormField(
                controller: emailController,
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
              ElevatedButton(onPressed: (){
          login();
              }, child: Text("Login")),
                              SizedBox(height: 20,),

              GestureDetector(onTap: (){
            Navigator.pushNamed(context, "/signup");
          },
          child: Text("Don't have an account?... Sign up"),),
             
              
            ],
          ),
        ),
      ),
    );

  }
}