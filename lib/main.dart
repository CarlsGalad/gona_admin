import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gona_admin/account_creation/auth_page.dart';

import 'package:gona_admin/firebase_options.dart';

import 'watcher.dart';

// import 'home/admin_home.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.web,
  );

  // Create an instance of the OrderWatcherService
  OrderWatcherService orderWatcherService = OrderWatcherService();

  // Start watching order items
  orderWatcherService.startWatching();

  runApp(const GonaAdmin());
}

class GonaAdmin extends StatelessWidget {
  const GonaAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AuthPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
