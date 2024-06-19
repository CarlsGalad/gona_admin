import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gona_admin/account_creation/auth_page.dart';
import 'package:gona_admin/firebase_options.dart';
import 'package:gona_admin/watcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with specified options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.web,
  );
  
  // Start the app after initializing services
  runApp(const GonaAdmin());
}

class GonaAdmin extends StatelessWidget {
  const GonaAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize and start OrderWatcherService after the app is built
    return FutureBuilder(
      future: _initializeServices(),
      builder: (context, snapshot) {
        // Show a loading spinner until the services are initialized
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Error initializing services: ${snapshot.error}'));
        } else {
          return const MaterialApp(
            home: AuthPage(),
            debugShowCheckedModeBanner: false,
          );
        }
      },
    );
  }

  // Function to initialize services asynchronously
  Future<void> _initializeServices() async {
    // Create an instance of the OrderWatcherService and start watching
    OrderWatcherService orderWatcherService = OrderWatcherService();
    orderWatcherService.startWatching();
  }
}
