import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpPage extends StatefulWidget {
  final Function()? onTap;

  const SignUpPage({super.key, required this.onTap});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Text editing controllers
  final emailController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Sign up user method
  void signUserUp() async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Check if passwords match
      if (passwordController.text.trim() !=
          confirmPasswordController.text.trim()) {
        Navigator.pop(context);
        showErrorMessage("Passwords don't match!");
        return;
      }

      // Create new user
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Save user details to Firestore
      await saveUserDetailsToFirestore();

      // Pop the loading indicator
      if (mounted) Navigator.pop(context);
      // Navigate to another screen or show success message
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      showErrorMessage(e.message ?? 'Sign-up failed');
    } catch (e) {
      Navigator.pop(context);
      showErrorMessage('An unexpected error occurred');
    }
  }

  // Save user details to Firestore
  Future<void> saveUserDetailsToFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        await firestore.collection('admin').doc(user.uid).set({
          'email': emailController.text.trim(),
          'firstName': firstNameController.text.trim(),
          'lastName': lastNameController.text.trim(),
          'mobile': mobileController.text.trim(),
          'userId': user.uid,
          'status': 'active',
          'birthDate': '',
          'qualification': [
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
      } catch (e) {
        showErrorMessage('Failed to save user details');
        rethrow;
      }
    }
  }

  // Show error snackbar
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
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 1024) {
            // Large screen layout
            return Row(
              children: [
                // App logo and title
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 150,
                        child: Image.asset(
                          'lib/images/logo_plain.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Text(
                        'Gona Market Africa',
                        style: GoogleFonts.agbalumo(fontSize: 20),
                      ),
                      Text(
                        'Admin Workspace',
                        style: GoogleFonts.abel(fontSize: 20),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: Center(
                      child: buildSignUpForm(),
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Small screen layout
            return Center(
              child: SingleChildScrollView(
                child: buildSignUpForm(),
              ),
            );
          }
        },
      ),
    );
  }

  Widget buildSignUpForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 25),
        Text(
          'Sign up',
          style: GoogleFonts.bebasNeue(fontSize: 30),
        ),
        const SizedBox(height: 10),
        // Email input textfield
        buildTextField(
          controller: emailController,
          hintText: 'Email',
        ),
        const SizedBox(height: 10),

        // First and Last name fields
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Row(
            children: [
              Expanded(
                child: buildTextFieldNames(
                  controller: firstNameController,
                  hintText: 'First Name',
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: buildTextFieldNames(
                  controller: lastNameController,
                  hintText: 'Last Name',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),

        // Phone number field
        buildTextField(
          controller: mobileController,
          hintText: 'Phone',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 15),

        // Password textfield
        buildTextField(
          controller: passwordController,
          hintText: 'Password',
          obscureText: true,
        ),
        const SizedBox(height: 15),

        // Confirm Password textfield
        buildTextField(
          controller: confirmPasswordController,
          hintText: 'Confirm Password',
          obscureText: true,
        ),
        const SizedBox(height: 15),

        // Sign up button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: MaterialButton(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            elevation: 18,
            color: Colors.green.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            onPressed: signUserUp,
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Toggle button to navigate back to login screen
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Already have an account?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: widget.onTap,
              child: const Text(
                '  Sign In now',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget buildTextFieldNames({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
