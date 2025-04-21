import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    var url = Uri.parse('https://v6.exchangerate-api.com/v6/e0190f187a9c913d9f63e7e4/latest/USD');
    var response = await http.get(url);
    var data = jsonDecode(response.body);
    setState(() {
      currencyMap = Map<String, dynamic>.from(data['conversion_rates']);
      currencyList = currencyMap.keys.toList();
    });
  }

  Map<String, dynamic> currencyMap = {};
  List<String> currencyList = [];
  String? selectedCurrency;

  final _formKey = GlobalKey<FormState>();

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController currencyController = TextEditingController();

  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  signup() async {
    if (_formKey.currentState!.validate()) {
      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Passwords do not match")),
        );
        return;
      }
      setState(() => isLoading = true);
      try {
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        final uid = credential.user!.uid;

        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'username': usernameController.text,
          'email': emailController.text,
          'phone': phoneController.text,
          'baseCurrency': currencyController.text,
        });

        usernameController.clear();
        emailController.clear();
        phoneController.clear();
        currencyController.clear();
        passwordController.clear();
        confirmPasswordController.clear();

        Navigator.pushReplacementNamed(context, '/login');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("The password provided is too weak.")));
        } else if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("The account already exists for that email.")));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("An error occurred")));
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  InputDecoration _inputDecoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Color(0xFF388E3C)),
      hintText: hint,
       hintStyle: TextStyle(color: Colors.grey[600], fontSize: 15),
      suffixIcon: Icon(icon, color: Colors.grey,size:18),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFF388E3C)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFF388E3C), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( 
            child: Column(
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
           
            mainAxisSize: MainAxisSize.min,
            children: [
             Align(
  alignment: Alignment.centerLeft,
  child: Text(
    "Welcome to us,",
    style: TextStyle(fontSize: 28, color: Color(0xFF388E3C), fontWeight: FontWeight.bold),
  ),
),
Align(
  alignment: Alignment.centerLeft,
  child: Text(
    "Hello there, create a profile",
    style: TextStyle(fontSize: 18, color: Colors.black),
  ),
),SizedBox(height: 40), 
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
  child: Icon(Icons.mobile_screen_share_outlined, color: Color.fromARGB(255, 64, 160, 69), size: 80),
),
              SizedBox(height: 40),

              TextFormField(
                controller: usernameController,
                decoration:  _inputDecoration('Username', 'Enter your username', Icons.person),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Username is required';
                  return null;
                },
              ),
              SizedBox(height: 30),

              TextFormField(
                controller: emailController,
                decoration:  _inputDecoration('Email', 'Enter your email', Icons.email),
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
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration('Phone Number', 'Enter your phone number', Icons.phone),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Phone number is required';
                  if (value.length < 10) return 'Enter a valid phone number';
                  return null;
                },
              ),
              SizedBox(height: 30),

           Autocomplete<String>(
  optionsBuilder: (TextEditingValue textEditingValue) {
    if (currencyList.isEmpty) return const Iterable<String>.empty();
    if (textEditingValue.text.isEmpty) {
      return currencyList;
    }
    return currencyList.where((c) => c.toLowerCase().contains(textEditingValue.text.toLowerCase()));
  },
  fieldViewBuilder: (context, fieldController, focusNode, onFieldSubmitted) {
    return TextFormField(
      controller: fieldController,
      focusNode: focusNode,
      decoration: _inputDecoration('Currency', 'Select your currency', Icons.currency_exchange),
      validator: (value) => value == null || value.isEmpty ? "Please select your currency" : null,
    );
  },
  optionsViewBuilder: (context, onSelected, options) {
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: MediaQuery.of(context).size.width - 48, 
          constraints: BoxConstraints(maxHeight: 200),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options.elementAt(index);
              return ListTile(
                title: Text(option),
                onTap: () {
                  onSelected(option);
                },
              );
            },
          ),
        ),
      ),
    );
  },
  onSelected: (String selection) {
    setState(() {
      selectedCurrency = selection;
      currencyController.text = selection;
    });
  },
),
  SizedBox(height: 30),

        TextFormField(
  controller: passwordController,
  obscureText: _obscurePassword,
  decoration: _inputDecoration('Password', 'Enter password', Icons.lock).copyWith(
    suffixIcon: IconButton(
      onPressed: () {
        setState(() {
          _obscurePassword = !_obscurePassword;
        });
      },
      icon: Icon(
        _obscurePassword ? Icons.visibility_off : Icons.visibility,
        color: Colors.grey,
        size: 18,
      ),
    ),
  ),
  validator: (value) {
    if (value == null || value.length < 6) return 'Minimum 6 characters required';
    return null;
  },
),
     SizedBox(height: 30),

         TextFormField(
  controller: confirmPasswordController,
  obscureText: _obscureConfirmPassword,
  decoration: _inputDecoration('Confirm Password', 'Re-enter password', Icons.lock_outline).copyWith(
    suffixIcon: IconButton(
      onPressed: () {
        setState(() {
          _obscureConfirmPassword = !_obscureConfirmPassword;
        });
      },
      icon: Icon(
        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
        color: Colors.grey,
        size: 18,
      ),
    ),
  ),
  validator: (value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    return null;
  },
),
     SizedBox(height: 40),

             isLoading
  ? Center(child: CircularProgressIndicator(color: Color(0xFF388E3C)))
  : SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: signup,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF388E3C),
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text("Sign Up", style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    ),

              SizedBox(height: 30),

             Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Text("Already have an account? ", style: TextStyle(color: Colors.black)),
     SizedBox(width: 5,),
    GestureDetector(
      onTap: () => Navigator.pushNamed(context, "/login"),
      child: Text("Login", style: TextStyle(color: Color(0xFF388E3C), fontWeight: FontWeight.bold)),
   ),
                      ],
                    ),
                  ],
                ),
              ),
            ),       SizedBox(height: 30),
           ],
        ),
      ),
    );
  }
   }
