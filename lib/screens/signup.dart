import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {

  final _formKey = GlobalKey<FormState>();


  final TextEditingController emailController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
bool isLoading = false;

  // Signup logic
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

        emailController.clear();
        numberController.clear();
        countryController.clear();
        passwordController.clear();
        confirmPasswordController.clear();

        Navigator.pushReplacementNamed(context, '/login');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
           print('The password provided is too weak.');
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("The password provided is too weak.")));
        } else if (e.code == 'email-already-in-use') {
          print('The account already exists for that email.');
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("The account already exists for that email.")));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("An error occurred")));
      }
      finally {
      setState(() => isLoading = false); 
    }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
           
            children: [
           
              Text("Sign Up", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              SizedBox(height: 40),

              // Email
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  label: Text("Email"),
                  hintText: "Enter your email",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Email is required';
                  if (!value.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
              SizedBox(height: 30),

              // Phone Number
              TextFormField(
                controller: numberController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  label: Text("Phone Number"),
                  hintText: "Enter your phone number",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Phone number is required';
                  if (value.length < 10) return 'Enter a valid phone number';
                  return null;
                },
              ),
              SizedBox(height: 30),

              // Country picker
              TextFormField(
                readOnly: true,
                controller: countryController,
                onTap: () {
                  showCountryPicker(
                    context: context,
                    showPhoneCode: false,
                    onSelect: (Country country) {
                      countryController.text = "${country.flagEmoji} ${country.name}";
                    },
                  );
                },
                decoration: InputDecoration(
                  labelText: "Select Country",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                validator: (value) => value!.isEmpty ? "Please select your country" : null,
              ),
              SizedBox(height: 30),

              // Password
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  label: Text("Password"),
                  hintText: "Enter password",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.length < 6) return 'Minimum 6 characters required';
                  return null;
                },
              ),
              SizedBox(height: 30),

              // Confirm password
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  label: Text("Confirm Password"),
                  hintText: "Re-enter your password",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please confirm your password';
                  return null;
                },
              ),
              SizedBox(height: 40),
isLoading
  ? Center(child: CircularProgressIndicator())
  : ElevatedButton(
  onPressed: signup,
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF388E3C),
    
  ), child: Text("Sign Up",style: TextStyle(fontSize: 16, color: Colors.white)), 
),
              SizedBox(height: 20),

              GestureDetector(
                onTap: () => Navigator.pushNamed(context, "/login"),
                child: Center(
                  child: Text("Already have an account?... Login", style: TextStyle(color: Colors.blue)),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
