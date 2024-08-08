import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gona_admin/home/sub_screens/delivered_orders.dart';
import 'package:gona_admin/home/sub_screens/shipped_orders.dart';

import 'package:gona_admin/home/sub_screens/pending_orders.dart';
import 'package:gona_admin/home/sub_screens/processed_orders.dart';
import 'package:gona_admin/services/admin_service.dart';

import 'main_home.dart'; // Import the AdminService

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Track selected bottom navigation bar item
  String? adminId = FirebaseAuth
      .instance.currentUser!.uid; // Replace with the actual admin ID logic

  // List of screens for navigation
  final List<Widget> _screens = [
    const MainHome(),
    const PendingOrderScreen(),
    const ProcessedOrderScreen(),
    const ShippedOrderScreen(),
    const DeliveredOrderScreen(),
  ];

  // Get the name of the screen based on the index
  String _getScreenNameByIndex(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Pending Orders';
      case 2:
        return 'Processed Orders';
      case 3:
        return 'Shipped Orders';
      case 4:
        return 'Delivered Orders';
      default:
        return 'Unknown';
    }
  }

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    // Log the navigation action
    if (adminId != null) {
      String screenName = _getScreenNameByIndex(index);
      await AdminService()
          .logActivity(adminId!, 'Navigation', 'Navigated to $screenName');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Colors.white,
        child: Scaffold(
          backgroundColor: Colors.grey[900],
          body: _screens[_selectedIndex],
          bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
                // sets the background color of the `BottomNavigationBar`
                canvasColor: Colors.white,
                // sets the active color of the `BottomNavigationBar` if `Brightness` is light
                primaryColor: Colors.white,
                textTheme: Theme.of(context).textTheme.copyWith()),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20)),
              child: BottomNavigationBar(
                elevation: 2,
                unselectedItemColor: Colors.grey,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard_outlined),
                    label: 'Dashboard',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.hourglass_empty),
                    label: 'Pending Orders',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.done_all),
                    label: 'Processed Orders',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.flight_takeoff),
                    label: 'Shipped Orders',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.handshake),
                    label: 'Delivered Orders',
                  ),
                  // ... other items for sub-screens
                ],
                currentIndex: _selectedIndex,
                selectedItemColor: Colors.orange.shade200,
                onTap: _onItemTapped,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
