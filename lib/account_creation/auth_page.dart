import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gona_admin/home/admin_home.dart';

import 'signin_or_register.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //we use a stream builder to check if the user is logged in or not,
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // user is logged in
          if (snapshot.hasData) {
            // handle case, navigate >
            return const AdminHome();
          }

          // if user is not logged in
          else {
            //handle case Navigate >
            return const SigninOrRegisterPage();
          }
        },
      ),
    );
  }
}
