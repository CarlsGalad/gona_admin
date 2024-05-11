import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'sign_up_page.dart';


class SigninOrRegisterPage extends StatefulWidget {
  const SigninOrRegisterPage({super.key});

  @override
  State<SigninOrRegisterPage> createState() => _SigninOrRegisterPageState();
}

class _SigninOrRegisterPageState extends State<SigninOrRegisterPage> {
  // Show  the login screen on start
  bool showSigninPage = true;

// a method to toggle between screens
  void togglePages() {
    setState(() {
      showSigninPage = !showSigninPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showSigninPage) {
      //the condition is true by default so >>
      return LoginPage(
        onTap: togglePages,
      );
    } else {
      // else go to sign up screen
      return SingUpPage(
        onTap: togglePages,
      );
    }
  }
}
