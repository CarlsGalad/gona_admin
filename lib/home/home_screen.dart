import 'package:flutter/material.dart';
import 'package:gona_admin/home/sub_screens/delivered_orders.dart';
import 'package:gona_admin/home/sub_screens/shipped_orders.dart';
import 'main_home.dart';
import 'sub_screens/pending_orders.dart';
import 'sub_screens/processed_orders.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Track selected bottom navigation bar item

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      const MainHome(), // Your main content screen
      const PendingOrderScreen(),
      const ProcessedOrderScreen(),
      const ShippedOrderScreen(),
      const DeliveredOrderScreen(),
    ];
    return Expanded(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _screens[_selectedIndex],
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
              // sets the background color of the `BottomNavigationBar`
              canvasColor: Colors.black,
              // sets the active color of the `BottomNavigationBar` if `Brightness` is light
              primaryColor: Colors.black,
              textTheme: Theme.of(context).textTheme.copyWith()),
          child: BottomNavigationBar(
            unselectedItemColor: Colors.blueAccent,
            showSelectedLabels: true,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.access_time),
                label: 'Pending Orders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.done_all),
                label: 'Processed Orders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_shipping_outlined),
                label: 'Shipped Orders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.delivery_dining),
                label: 'Delivered Orders',
              ),
              // ... other items for sub-screens
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.blue,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}
