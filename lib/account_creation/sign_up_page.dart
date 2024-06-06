import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class SingUpPage extends StatefulWidget {
  final Function()? onTap;

  const SingUpPage({super.key, required this.onTap});

  @override
  State<SingUpPage> createState() => _SingUpPageState();
}

class _SingUpPageState extends State<SingUpPage> {
  //Text editing controllers
  final emailController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

// sign user up method
  void signUserUp() async {
    // show loading circle
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child:
                CircularProgressIndicator(), //TODO: change the loading indicator
          );
        });

// Create new  gona Admin
    try {
      //check if password correponds
      if (passwordController.text == confirmPasswordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text, password: passwordController.text);
        // Save user details to Firestore
        saveUserDetailsToFirestore();
      } else {
        // show error message, passwords dont't match
        showErrorMessage("Passwords down't match!");
      }
      if (!mounted) {
        return;
      }
      //pop the progress indicator
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      //pop progress indicator
      Navigator.pop(context);
      //if wrong email
      if (e.code == 'user=not-found') {
        // Show error to user
        showErrorMessage(e.message ?? 'Sign-up failed');
      }
    }
  }

  // Save user details to Firestore
  void saveUserDetailsToFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Access Firestore instance
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        // Save user details to Firestore
        await firestore.collection('admin').doc(user.uid).set({
          'email': emailController.text,
          'firstName': firstNameController.text,
          'lastName': lastNameController.text,
          'mobile': mobileController.text,
          'userId': user.uid,
          'status': 'active',
          'D.O.B': '',
          'Qualification': [
            {
              'institution': '',
              'courseStudied': '',
              'certificateNo': '',
              'year': '',
            }
          ],
          'department': '',
          'role': '',
          'address': '',
          'nextOfKin': '',
          'nextOfKinMobile': '',
          'nextOfKinMail': '',
          'activityLog': [],
        });
        if (!mounted) return;
        // Pop the progress indicator
        Navigator.pop(context);
      } catch (e) {
        // Pop the progress indicator
        Navigator.pop(context);
        // Show error message
        showErrorMessage('Failed to save user details');
      }
    }
  }

  // show error snackbar
  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: const DecorationImage(
              image: AssetImage("lib/images/Generated.jpeg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Row(
            children: [
// app logo
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.transparent,
                  ),
                  child: Center(
                    child: Container(
                      height: 350,
                      width: 350,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(30)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          'lib/images/Gona logo.jpeg', // The background image
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 25,
                          ),

                          Text('Let\'s sign you up',
                              style: GoogleFonts.bebasNeue(
                                  fontSize: 30, color: Colors.white)),
                          const SizedBox(
                            height: 10,
                          ),

                          //Email input textfield
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 25.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: TextField(
                                  controller: emailController,
                                  decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Email'),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          // first name field
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 25.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: TextField(
                                  controller: firstNameController,
                                  decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'First Name'),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15.0),

                          // Last name Field
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 25.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: TextField(
                                  controller: lastNameController,
                                  decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Last Name'),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15.0),

                          // Phone number filed
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 25.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: TextField(
                                  keyboardType: TextInputType.phone,
                                  controller: mobileController,
                                  decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Phone'),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15.0),
                          //Password textfield
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 25.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: TextField(
                                  controller: passwordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Password'),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15.0),
                          // confirm Password textfield
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 25.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: TextField(
                                  controller: confirmPasswordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Confirm Password'),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15.0),

                          const SizedBox(height: 15.0),

                          //sign in button
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 25.0),
                            child: GestureDetector(
                              onTap: () {
                                signUserUp();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(255, 49, 105, 11),
                                    borderRadius: BorderRadius.circular(20)),
                                child: const Center(
                                  child: Text(
                                    'Sign Up',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          // the toggle button navigates back to login screen
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Already have an account?',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              GestureDetector(
                                onTap: widget.onTap,
                                child: const Text(
                                  '  Sign In now',
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                        ],
                      ),
                    ),
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
