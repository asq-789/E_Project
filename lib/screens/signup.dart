import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {

  final _formKey = GlobalKey<FormState>();

   TextEditingController usernameController = TextEditingController();
   TextEditingController emailController = TextEditingController();
   TextEditingController phoneController = TextEditingController();
   TextEditingController passwordController = TextEditingController();
   TextEditingController confirmPasswordController = TextEditingController();
   TextEditingController countryController = TextEditingController();
bool isLoading = false;
bool _obscurePassword = true;
bool _obscureConfirmPassword = true;
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

                  final uid = credential.user!.uid;
                  
await FirebaseFirestore.instance.collection('users').doc(uid).set({
'username':usernameController.text,
'email' :emailController.text,
'phone':phoneController.text,
 'country': countryController.text, 
});
usernameController.clear();
        emailController.clear();
        phoneController.clear();
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
        print("Signup Error: $e");
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

              TextFormField(
  controller: usernameController,
  decoration: InputDecoration(
    label: Text("Username"),
    hintText: "Enter your username",
    border: OutlineInputBorder(),
  ),
  validator: (value) {
    if (value == null || value.isEmpty) return 'Username is required';
    return null;
  },
),
SizedBox(height: 30),

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
                controller: phoneController,
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

              
              TextFormField(
                controller: passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  label: Text("Password"),
                  hintText: "Enter password",
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: (){
setState(() {
  _obscurePassword=!_obscurePassword;
});
                    }, icon:Icon( _obscurePassword? Icons.visibility_off : Icons.visibility,
)),
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
  decoration: InputDecoration(
    label: Text("Confirm Password"),
    hintText: "Re-enter your password",
    border: OutlineInputBorder(),
    suffixIcon: IconButton(
      icon: Icon(
        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
      ),
      onPressed: () {
        setState(() {
          _obscureConfirmPassword = !_obscureConfirmPassword;
        });
      },
    ),
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
